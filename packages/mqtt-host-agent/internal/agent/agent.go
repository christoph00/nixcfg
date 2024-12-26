package agent

import (
	MQTT "github.com/eclipse/paho.mqtt.golang"

	"github.com/christoph00/mqtt-host-agent/internal/config"
	"github.com/christoph00/mqtt-host-agent/internal/discovery"
	"github.com/christoph00/mqtt-host-agent/internal/logger"
)

type MQTTHostAgent struct {
	client    MQTT.Client
	config    *config.Config
	hostname  string
	baseTopic string
	version   string
	logger    *logger.Logger
	discovery *discovery.Discovery
}
