package discovery

import (
	"github.com/christoph00/mqtt-host-agent/internal/config"
)

type Discovery struct {
	config     *config.Config
	hostname   string
	baseTopic  string
	mqttClient MQTTClient
}
