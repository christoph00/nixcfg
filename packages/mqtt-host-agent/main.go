package main

import (
    "encoding/json"
    "fmt"
    "os"
    "os/exec"
    "strings"
    "time"
    "log/syslog"


    MQTT "github.com/eclipse/paho.mqtt.golang"
)

const (
    haDiscoveryPrefix = "homeassistant"
)

type Logger struct {
    syslog *syslog.Writer
}

type Config struct {
    Broker struct {
        Host string `json:"host"`
        Port int    `json:"port"`
    } `json:"broker"`
    MqttUser        string            `json:"mqtt_user"`
    AllowedCommands map[string]string `json:"allowedCommands"`
}


type MQTTHostAgent struct {
    client          MQTT.Client
    config          Config
    hostname        string
    baseTopic       string
    version         string
    logger          *Logger
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

func NewLogger() (*Logger, error) {
    writer, err := syslog.New(syslog.LOG_INFO|syslog.LOG_DAEMON, "mqtt-host-agent")
    if err != nil {
        return nil, fmt.Errorf("failed to initialize syslog: %v", err)
    }
    return &Logger{syslog: writer}, nil
}

func (l *Logger) Info(format string, v ...interface{}) {
    msg := fmt.Sprintf(format, v...)
    l.syslog.Info(msg)
}

func (l *Logger) Error(format string, v ...interface{}) {
    msg := fmt.Sprintf(format, v...)
    l.syslog.Err(msg)
}

func (l *Logger) Warning(format string, v ...interface{}) {
    msg := fmt.Sprintf(format, v...)
    l.syslog.Warning(msg)
}


func NewMQTTHostAgent(configPath string) (*MQTTHostAgent, error) {
    logger, err := NewLogger()
    if err != nil {
        return nil, err
    }
    config := Config{}
    data, err := os.ReadFile(configPath)
    if err != nil {
        logger.Error("Failed to read config file: %v", err)
        return nil, err
    }
    
    if err := json.Unmarshal(data, &config); err != nil {
        logger.Error("Failed to parse config file: %v", err)
        return nil, err
    }

    hostname, err := os.Hostname()
    if err != nil {
        logger.Error("Failed to get hostname: %v", err)
        return nil, err
    }

    opts := MQTT.NewClientOptions()
    opts.AddBroker(fmt.Sprintf("tcp://%s:%d", config.Broker.Host, config.Broker.Port))
    opts.SetClientID(fmt.Sprintf("host_agent_%s", hostname))

    if config.MqttUser != "" {
    opts.SetUsername(config.MqttUser)
    if password := os.Getenv("MQTT_PASS"); password != "" {
        opts.SetPassword(password)
    } else {
        logger.Warning("MQTT_PASSWORD environment variable not set")
    }
}
    

    // Set last will
    lastWillTopic := fmt.Sprintf("mqd/%s/status", hostname)
    opts.SetWill(lastWillTopic, "offline", 1, true)

    client := MQTT.NewClient(opts)
    if token := client.Connect(); token.Wait() && token.Error() != nil {
        return nil, token.Error()
    }

    logger.Info("Successfully connected to MQTT broker at %s:%d", config.Broker.Host, config.Broker.Port)

    return &MQTTHostAgent{
        client:    client,
        config:    config,
        hostname:  hostname,
        baseTopic: fmt.Sprintf("mqd/%s", hostname),
        version:   "1.0.0",
        logger:    logger,
    }, nil


}

func (a *MQTTHostAgent) publishDiscoveryConfigs() {
    device := HADevice{
        Identifiers:  []string{a.hostname},
        Name:         a.hostname,
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


    // Commands
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

func (a *MQTTHostAgent) handleCustomCommand(cmdName string) {
    cmdString, ok := a.config.AllowedCommands[cmdName]
    if !ok {
        a.logger.Warning("Unauthorized command execution attempt: %s", cmdName)
        a.client.Publish(
            fmt.Sprintf("%s/cmd/%s/error", a.baseTopic, cmdName),
            0, false,
            "Command not in allowed list",
        )
        return
    }

    a.logger.Info("Executing custom command: %s (%s)", cmdName, cmdString)
    
    args := strings.Fields(cmdString)
    if len(args) == 0 {
        errMsg := "Empty command specified"
        a.logger.Error(errMsg)
        a.client.Publish(
            fmt.Sprintf("%s/cmd/%s/error", a.baseTopic, cmdName),
            0, false,
            errMsg,
        )
        return
    }

    go func() {
        cmd := exec.Command(args[0], args[1:]...)
        output, err := cmd.CombinedOutput()
        topic := fmt.Sprintf("%s/cmd/%s/result", a.baseTopic, cmdName)
        
        result := struct {
            StatusCode int    `json:"status_code"`
            Output    string `json:"output"`
        }{
            StatusCode: 0,
            Output:    "",
        }

        if err != nil {
            if exitErr, ok := err.(*exec.ExitError); ok {
                result.StatusCode = exitErr.ExitCode()
            } else {
                result.StatusCode = -1
            }
            result.Output = err.Error()
        } else {
            result.Output = string(output)
            if len(result.Output) > 100 {
                result.Output = result.Output[:100]
            }
        }

        jsonResult, _ := json.Marshal(result)
        a.client.Publish(topic, 0, false, string(jsonResult))
        a.logger.Info("Command completed: %s (status=%d)", cmdName, result.StatusCode)
    }()
}

func (a *MQTTHostAgent) Start() {

    a.logger.Info("Starting MQTT Host Agent")
    // Publish discovery configs
    a.publishDiscoveryConfigs()
    a.logger.Info("Published Home Assistant discovery configurations")

    // Publish online status
    a.client.Publish(
        fmt.Sprintf("%s/status", a.baseTopic),
        1,
        true,
        "online",
    )
    a.logger.Info("Published online status")
    // Subscribe to commands
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

    a.logger.Info("MQTT Host Agent started successfully")
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
