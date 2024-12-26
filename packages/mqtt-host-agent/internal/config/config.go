package config

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
