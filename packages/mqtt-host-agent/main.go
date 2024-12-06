package main

import (
	"encoding/json"
	"fmt"
	"log/syslog"
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
	AllowedCommands map[string]string `json:"allowedCommands"`
	WatchServices   []string          `json:"watchServices"`
	Discovery       DiscoveryConfig   `json:"haDiscovery"`
}

type DiscoveryConfig struct {
	Services     map[string]ServiceConfig `json:"services"`
	Commands     map[string]CommandConfig `json:"commands"`
	OnlineStatus OnlineStatusSensorConfig `json:"online_status"`
	Status       StatusSensorConfig       `json:"status"`
}
type ServiceConfig struct {
	Component       string       `json:"component"`
	Name            string       `json:"name"`
	UniqueID        string       `json:"unique_id"`
	CommandTopic    string       `json:"command_topic"`
	StateTopic      string       `json:"state_topic"`
	ValueTemplate   string       `json:"value_template"`
	CommandTemplate string       `json:"command_template"`
	Options         []string     `json:"options"`
	Icon            string       `json:"icon"`
	Device          DeviceConfig `json:"device"`
}

type OnlineStatusSensorConfig struct {
	Component     string       `json:"component"`
	Name          string       `json:"name"`
	UniqueID      string       `json:"unique_id"`
	StateTopic    string       `json:"state_topic"`
	ValueTemplate string       `json:"value_template"`
	PayloadOn     string       `json:"payload_on"`
	PayloadOff    string       `json:"payload_off"`
	DeviceClass   string       `json:"device_class"`
	ExpireAfter   int          `json:"expire_after"`
	Icon          string       `json:"icon"`
	Device        DeviceConfig `json:"device"`
}

type StatusSensorConfig struct {
	Component         string       `json:"component"`
	Name              string       `json:"name"`
	UniqueID          string       `json:"unique_id"`
	StateTopic        string       `json:"state_topic"`
	AvailabilityTopic string       `json:"availability_topic"`
	Icon              string       `json:"icon"`
	Device            DeviceConfig `json:"device"`
}

type CommandConfig struct {
	Component    string       `json:"component"`
	Name         string       `json:"name"`
	UniqueID     string       `json:"unique_id"`
	CommandTopic string       `json:"command_topic"`
	StateTopic   string       `json:"state_topic"`
	PayloadPress string       `json:"payload_press,omitempty"`
	Icon         string       `json:"icon"`
	Device       DeviceConfig `json:"device"`
}

type DeviceConfig struct {
	Identifiers  []string `json:"identifiers"`
	Name         string   `json:"name"`
	Model        string   `json:"model"`
	Manufacturer string   `json:"manufacturer"`
}

type CommandExecution struct {
	Command   string   `json:"command"`
	Arguments []string `json:"arguments,omitempty"`
}

type Logger struct {
	syslog *syslog.Writer
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

type MQTTHostAgent struct {
	client    MQTT.Client
	config    Config
	hostname  string
	baseTopic string
	version   string
	logger    *Logger
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
			logger.Warning("MQTT_PASS environment variable not set")
		}
	}

	// Set last will
	lastWillTopic := fmt.Sprintf("mqd/%s/status", hostname)
	opts.SetWill(lastWillTopic, "offline", 1, true)

	client := MQTT.NewClient(opts)
	if token := client.Connect(); token.Wait() && token.Error() != nil {
		logger.Error("Failed to connect to MQTT broker: %v", token.Error())
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

func (a *MQTTHostAgent) publishCommandError(cmdName, errMsg string) {
	a.client.Publish(
		fmt.Sprintf("%s/command/%s/error", a.baseTopic, cmdName),
		0, false,
		errMsg,
	)
}

func (a *MQTTHostAgent) handleCustomCommand(cmdName string, payload []byte) {
	baseCmd, ok := a.config.AllowedCommands[cmdName]
	if !ok {
		a.logger.Warning("Unauthorized command execution attempt: %s", cmdName)
		a.publishCommandError(cmdName, "Command not in allowed list")
		return
	}

	var execution CommandExecution
	if len(payload) > 0 {
		if err := json.Unmarshal(payload, &execution); err != nil {
			a.logger.Error("Failed to parse command payload: %v", err)
			a.publishCommandError(cmdName, "Invalid payload format")
			return
		}
	}

	args := strings.Fields(baseCmd)
	args = append(args, execution.Arguments...)

	a.logger.Info("Executing command: %s with args: %v", args[0], args[1:])

	go func() {
		cmd := exec.Command(args[0], args[1:]...)
		output, err := cmd.CombinedOutput()

		result := struct {
			StatusCode int       `json:"status_code"`
			Output     string    `json:"output"`
			Command    string    `json:"command"`
			Args       []string  `json:"args"`
			Timestamp  time.Time `json:"timestamp"`
		}{
			StatusCode: 0,
			Command:    args[0],
			Args:       args[1:],
			Timestamp:  time.Now(),
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
		a.client.Publish(
			fmt.Sprintf("%s/command/%s/result", a.baseTopic, cmdName),
			0, false,
			string(jsonResult),
		)

		a.logger.Info("Command completed: %s (status=%d)", cmdName, result.StatusCode)
	}()
}

func (a *MQTTHostAgent) publishDiscoveryConfigs() {
	discoveryPrefix := "homeassistant"
	deviceConfig := DeviceConfig{
		Identifiers:  []string{fmt.Sprintf("agent-%s", a.hostname)},
		Name:         a.hostname,
		Model:        "MQTT Host Agent",
		Manufacturer: "NixOS",
	}

	// Online Status Sensor
	onlineStatusConfig := OnlineStatusSensorConfig{
		Component:     "binary_sensor",
		Name:          fmt.Sprintf("%s Online Status", a.hostname),
		UniqueID:      fmt.Sprintf("%s_online_status", a.hostname),
		StateTopic:    fmt.Sprintf("%s/heartbeat", a.baseTopic),
		ValueTemplate: "{{ 'ON' if ((as_timestamp(now()) - as_timestamp(value)) | int < 50) else 'OFF' }}",
		PayloadOn:     "ON",
		PayloadOff:    "OFF",
		DeviceClass:   "connectivity",
		ExpireAfter:   50,
		Icon:          "mdi:server-network",
		Device:        deviceConfig,
	}

	// Status Sensor
	statusConfig := StatusSensorConfig{
		Component:         "sensor",
		Name:              fmt.Sprintf("%s Status", a.hostname),
		UniqueID:          fmt.Sprintf("%s_status", a.hostname),
		StateTopic:        fmt.Sprintf("%s/status", a.baseTopic),
		AvailabilityTopic: fmt.Sprintf("%s/status", a.baseTopic),
		Icon:              "mdi:server",
		Device:            deviceConfig,
	}

	// Publish Online Status Sensor Config
	onlineStatusTopic := fmt.Sprintf("%s/binary_sensor/%s/online_status/config",
		discoveryPrefix,
		a.hostname,
	)
	if err := a.publishConfig(onlineStatusTopic, onlineStatusConfig); err != nil {
		a.logger.Error("Failed to publish online status config: %v", err)
	}

	// Publish Status Sensor Config
	statusTopic := fmt.Sprintf("%s/sensor/%s/status/config",
		discoveryPrefix,
		a.hostname,
	)
	if err := a.publishConfig(statusTopic, statusConfig); err != nil {
		a.logger.Error("Failed to publish status config: %v", err)
	}

	for cmdName := range a.config.AllowedCommands {
		config := CommandConfig{
			Component:    "button",
			Name:         fmt.Sprintf("Command %s", cmdName),
			UniqueID:     fmt.Sprintf("command_%s", cmdName),
			CommandTopic: fmt.Sprintf("%s/command/%s", a.baseTopic, cmdName),
			StateTopic:   fmt.Sprintf("%s/command/%s/result", a.baseTopic, cmdName),
			PayloadPress: "{}",
			Icon:         "mdi:console",
			Device:       deviceConfig,
		}

		topic := fmt.Sprintf("%s/button/%s/%s/config",
			discoveryPrefix,
			a.hostname,
			cmdName,
		)

		if err := a.publishConfig(topic, config); err != nil {
			a.logger.Error("Failed to publish command config for %s: %v", cmdName, err)
		}
	}
}

func (a *MQTTHostAgent) publishConfig(topic string, config interface{}) error {
	configJson, err := json.Marshal(config)
	if err != nil {
		return fmt.Errorf("failed to marshal config: %v", err)
	}

	token := a.client.Publish(topic, 0, true, configJson)
	if token.Wait() && token.Error() != nil {
		return fmt.Errorf("failed to publish config: %v", token.Error())
	}

	return nil
}

func (a *MQTTHostAgent) Start() {
	a.logger.Info("Starting MQTT Host Agent")

	// Publish discovery configs
	a.publishDiscoveryConfigs()
	a.logger.Info("Published Home Assistant discovery configurations")

	// Subscribe to command topics
	commandTopic := fmt.Sprintf("%s/command/+", a.baseTopic)
	if token := a.client.Subscribe(commandTopic, 0, func(client MQTT.Client, msg MQTT.Message) {
		cmdName := strings.Split(msg.Topic(), "/")[3]
		a.handleCustomCommand(cmdName, msg.Payload())
	}); token.Wait() && token.Error() != nil {
		a.logger.Error("Failed to subscribe to command topic: %v", token.Error())
		return
	}

	// Publish online status
	a.client.Publish(
		fmt.Sprintf("%s/status", a.baseTopic),
		1,
		true,
		"online",
	)
	a.logger.Info("Published online status")

	// Start heartbeat
	go func() {
		for {
			// ISO8601 Zeitstempel senden
			timestamp := time.Now().Format(time.RFC3339)
			a.client.Publish(
				fmt.Sprintf("%s/heartbeat", a.baseTopic),
				0, true, // retained message
				timestamp,
			)
			time.Sleep(20 * time.Second)
		}
	}()

	a.logger.Info("MQTT Host Agent started successfully")
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
