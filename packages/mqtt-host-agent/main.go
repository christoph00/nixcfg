package main

import (
    "encoding/json"
    "fmt"
    "os"
    "os/exec"
    "strings"
    "time"

    MQTT "github.com/eclipse/paho.mqtt.golang"
)

type Config struct {
    Broker struct {
        Host string `json:"host"`
        Port int    `json:"port"`
    } `json:"broker"`
    MqttUser        string            `json:"mqtt_user"`
    AllowedServices []string          `json:"allowedServices"`
    AllowedCommands map[string]string `json:"allowedCommands"`
    WatchServices   []string          `json:"watchServices"`
}

type MQTTHostAgent struct {
    client          MQTT.Client
    config          Config
    hostname        string
    baseTopic       string
}

func NewMQTTHostAgent(configPath string) (*MQTTHostAgent, error) {
    config := Config{}
    data, err := os.ReadFile(configPath)
    if err != nil {
        return nil, err
    }
    
    if err := json.Unmarshal(data, &config); err != nil {
        return nil, err
    }

    hostname, err := os.Hostname()
    if err != nil {
        return nil, err
    }

    opts := MQTT.NewClientOptions()
    opts.AddBroker(fmt.Sprintf("tcp://%s:%d", config.Broker.Host, config.Broker.Port))
    opts.SetClientID(fmt.Sprintf("host_agent_%s", hostname))
    
    if password := os.Getenv("MQTT_PASSWORD"); password != "" {
        opts.SetUsername(config.MqttUser)
        opts.SetPassword(password)
    }

    client := MQTT.NewClient(opts)
    if token := client.Connect(); token.Wait() && token.Error() != nil {
        return nil, token.Error()
    }

    return &MQTTHostAgent{
        client:    client,
        config:    config,
        hostname:  hostname,
        baseTopic: fmt.Sprintf("mqd/%s", hostname),
    }, nil
}

func (a *MQTTHostAgent) handleServiceCommand(service, action string) {
    if !contains(a.config.AllowedServices, service) {
        a.client.Publish(
            fmt.Sprintf("%s/service/%s/error", a.baseTopic, service),
            0, false,
            "Service not in allowed list",
        )
        return
    }

    cmd := exec.Command("systemctl", action, service)
    output, err := cmd.CombinedOutput()
    topic := fmt.Sprintf("%s/service/%s/status", a.baseTopic, service)
    
    if err != nil {
        a.client.Publish(topic, 0, false, fmt.Sprintf("Error: %s", err))
        return
    }
    
    a.client.Publish(topic, 0, false, string(output))
}

func (a *MQTTHostAgent) handleCustomCommand(cmdName string) {
    cmd, ok := a.config.AllowedCommands[cmdName]
    if !ok {
        a.client.Publish(
            fmt.Sprintf("%s/cmd/%s/error", a.baseTopic, cmdName),
            0, false,
            "Command not in allowed list",
        )
        return
    }

    output, err := exec.Command("sh", "-c", cmd).CombinedOutput()
    topic := fmt.Sprintf("%s/cmd/%s/result", a.baseTopic, cmdName)
    
    if err != nil {
        a.client.Publish(topic, 0, false, fmt.Sprintf("Error: %s", err))
        return
    }
    
    a.client.Publish(topic, 0, false, string(output))
}

func (a *MQTTHostAgent) Start() {
    // Subscribe to service commands
    a.client.Subscribe(
        fmt.Sprintf("%s/service/+/+", a.baseTopic),
        0,
        func(client MQTT.Client, msg MQTT.Message) {
            parts := strings.Split(msg.Topic(), "/")
            service := parts[len(parts)-2]
            action := parts[len(parts)-1]
            a.handleServiceCommand(service, action)
        },
    )

    // Subscribe to custom commands
    a.client.Subscribe(
        fmt.Sprintf("%s/cmd/+", a.baseTopic),
        0,
        func(client MQTT.Client, msg MQTT.Message) {
            parts := strings.Split(msg.Topic(), "/")
            cmdName := parts[len(parts)-1]
            a.handleCustomCommand(cmdName)
        },
    )

    // Start heartbeat
    go func() {
        for {
            a.client.Publish(
                fmt.Sprintf("%s/heartbeat", a.baseTopic),
                0, false,
                "alive",
            )
            time.Sleep(20 * time.Second)
        }
    }()

    // Start service watchers
    for _, service := range a.config.WatchServices {
        go a.watchService(service)
    }
}

func (a *MQTTHostAgent) watchService(service string) {
    for {
        cmd := exec.Command("systemctl", "is-active", service)
        output, _ := cmd.CombinedOutput()
        if strings.TrimSpace(string(output)) == "failed" {
            a.client.Publish(
                fmt.Sprintf("%s/service/%s/alert", a.baseTopic, service),
                0, false,
                "Service failed",
            )
        }
        time.Sleep(5 * time.Second)
    }
}

func contains(slice []string, item string) bool {
    for _, s := range slice {
        if s == item {
            return true
        }
    }
    return false
}

func main() {
    if len(os.Args) != 2 {
        fmt.Println("Usage: mqtt-host-agent <config-file>")
        os.Exit(1)
    }

    agent, err := NewMQTTHostAgent(os.Args[1])
    if err != nil {
        fmt.Printf("Error initializing agent: %v\n", err)
        os.Exit(1)
    }

    agent.Start()
    select {} // Block forever
}
