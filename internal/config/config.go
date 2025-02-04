package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	APIKey      string
	APISecret   string
	AccessToken string
	ServerHost  string
	ServerPort  string
	NatsURL     string
	ServiceName string
	Version     string
}

func LoadConfig() *Config {
	err := godotenv.Load("config/.env")
	if err != nil {
		log.Printf("Error loading .env file: %v", err)
	}

	return &Config{
		APIKey:      getEnv("appKey", ""),
		APISecret:   getEnv("appSecret", ""),
		AccessToken: getEnv("accessToken", ""),
		ServerHost:  getEnv("SERVER_HOST", "localhost"),
		ServerPort:  getEnv("SERVER_PORT", "8100"),
		NatsURL:     getEnv("NATS_URL", ""),
		ServiceName: getEnv("NATS_SERVICE_NAME", ""),
		Version:     getEnv("NATS_SERVICE_VERSION", ""),
	}
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}
