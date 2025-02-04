package config

import (
	"time"

	"github.com/ilyakaznacheev/cleanenv"
	"github.com/joho/godotenv"
)

type natsConfig struct {
	URL     string        `env:"NATS_URL"`
	Name    string        `env:"NATS_SERVICE_NAME"`
	Version string        `env:"NATS_SERVICE_VERSION"`
	Timeout time.Duration `env:"NATS_TIMEOUT" env-default:"5s"`
}

type NatsConfig struct {
	nats natsConfig
}

func NewNatsConfig() *NatsConfig {
	_ = godotenv.Load()

	var cfg natsConfig
	if err := cleanenv.ReadEnv(&cfg); err != nil {
		panic("Failed to read NATS configuration")
	}

	return &NatsConfig{nats: cfg}
}

func (c *NatsConfig) GetURL() string {
	return c.nats.URL
}

func (c *NatsConfig) GetServiceName() string {
	return c.nats.Name
}

func (c *NatsConfig) GetServiceVersion() string {
	return c.nats.Version
}

func (c *NatsConfig) GetTimeout() time.Duration {
	return c.nats.Timeout
}
