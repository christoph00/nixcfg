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

type HADiscoveryConfig struct {
    Name              string `json:"name"`
    UniqueId          string `json:"unique_id"`
    StateTopic        string `json:"state_topic,omitempty"`
    CommandTopic      string `json:"command_topic,omitempty"`
    PayloadAvailable  string `json:"payload_available,omitempty"`
    PayloadNotAvailable string `json:"payload_not_available,omitempty"`
    Icon              string `json:"icon,omitempty"`
    Device           HADevice `json:"device"`
}

type HADevice struct {
    Identifiers  []string `json:"identifiers"`
    Name         string   `json:"name"`
    Model        string   `json:"model"`
    Manufacturer string   `json:"manufacturer"`
    SwVersion    string   `json:"sw_version"`
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

    agent := &MQTTHostAgent{
        client:    client,
        config:    config,
        hostname:  hostname,
        baseTopic: fmt.Sprintf("mqd/%s", hostname),
        version:   "1.0.0",
    }

    opts.SetWill(
        fmt.Sprintf("%s/status", agent.baseTopic),
        "offline",
        1,
        true,
    )

    return agent, nil

}

func (a *MQTTHostAgent) publishDiscoveryConfigs() {
    device := HADevice{
        Identifiers:  []string{a.hostname},
        Name:         fmt.Sprintf("MQTT Host Agent - %s", a.hostname),
        Model:        "MQTT Host Agent",
        Manufacturer: "NixOS",
        SwVersion:    a.version,
    }

    // Heartbeat Sensor
    a.publishDiscoveryConfig("binary_sensor", "heartbeat", HADiscoveryConfig{
        Name:              fmt.Sprintf("%s Heartbeat", a.hostname),
        UniqueId:          fmt.Sprintf("%s_heartbeat", a.hostname),
        StateTopic:        fmt.Sprintf("%s/heartbeat", a.baseTopic),
        PayloadAvailable:  "alive",
        PayloadNotAvailable: "dead",
        Icon:              "mdi:heart-pulse",
        Device:            device,
    })

    // Services
    for _, service := range a.config.AllowedServices {
        // Service Status Sensor
        a.publishDiscoveryConfig("sensor", fmt.Sprintf("service_%s", service), HADiscoveryConfig{
            Name:       fmt.Sprintf("%s Service %s Status", a.hostname, service),
            UniqueId:   fmt.Sprintf("%s_service_%s", a.hostname, service),
            StateTopic: fmt.Sprintf("%s/service/%s/status", a.baseTopic, service),
            Icon:       "mdi:cog",
            Device:     device,
        })

        // Service Control Button
        for _, action := range []string{"start", "stop", "restart"} {
            a.publishDiscoveryConfig("button", fmt.Sprintf("service_%s_%s", service, action), HADiscoveryConfig{
                Name:         fmt.Sprintf("%s Service %s %s", a.hostname, service, action),
                UniqueId:    fmt.Sprintf("%s_service_%s_%s", a.hostname, service, action),
                CommandTopic: fmt.Sprintf("%s/service/%s/%s", a.baseTopic, service, action),
                Icon:        fmt.Sprintf("mdi:power-%s", action),
                Device:      device,
            })
        }
    }

    // Custom Commands
    for cmdName := range a.config.AllowedCommands {
        a.publishDiscoveryConfig("button", fmt.Sprintf("cmd_%s", cmdName), HADiscoveryConfig{
            Name:         fmt.Sprintf("%s Command %s", a.hostname, cmdName),
            UniqueId:    fmt.Sprintf("%s_cmd_%s", a.hostname, cmdName),
            CommandTopic: fmt.Sprintf("%s/cmd/%s", a.baseTopic, cmdName),
            Icon:        "mdi:console",
            Device:      device,
        })

        // Command Result Sensor
        a.publishDiscoveryConfig("sensor", fmt.Sprintf("cmd_%s_result", cmdName), HADiscoveryConfig{
            Name:       fmt.Sprintf("%s Command %s Result", a.hostname, cmdName),
            UniqueId:   fmt.Sprintf("%s_cmd_%s_result", a.hostname, cmdName),
            StateTopic: fmt.Sprintf("%s/cmd/%s/result", a.baseTopic, cmdName),
            Icon:       "mdi:console-line",
            Device:     device,
        })
    }

    // Service Watchers
    for _, service := range a.config.WatchServices {
        a.publishDiscoveryConfig("binary_sensor", fmt.Sprintf("watch_%s", service), HADiscoveryConfig{
            Name:       fmt.Sprintf("%s Watch %s", a.hostname, service),
            UniqueId:   fmt.Sprintf("%s_watch_%s", a.hostname, service),
            StateTopic: fmt.Sprintf("%s/service/%s/alert", a.baseTopic, service),
            Icon:       "mdi:alert",
            Device:     device,
        })
    }
}

func (a *MQTTHostAgent) publishDiscoveryConfig(component string, name string, config HADiscoveryConfig) {
    topic := fmt.Sprintf("%s/%s/%s/%s/config", 
        haDiscoveryPrefix, 
        component, 
        a.hostname, 
        name,
    )
    
    payload, err := json.Marshal(config)
    if err != nil {
        fmt.Printf("Error marshaling discovery config: %v\n", err)
        return
    }

    token := a.client.Publish(topic, 0, true, payload)
    token.Wait()
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
    // Publish discovery configs
    a.publishDiscoveryConfigs()

    // Publish online status
    a.client.Publish(
        fmt.Sprintf("%s/status", a.baseTopic),
        1,
        true,
        "online",
    )

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
