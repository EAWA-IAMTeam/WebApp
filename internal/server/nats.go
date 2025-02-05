package server

import (
	"auth_ecommerce/internal/config" // ✅ Import correct config package
	"auth_ecommerce/internal/handlers"
	"auth_ecommerce/pkg/natserve"
	"fmt"
	"log"
)

// NATSServer holds the NATS client and configuration
type NATSServer struct {
	Client natserve.Client
}

// NewNATSServer initializes and returns a new NATSServer instance
func NewNATSServer(cfg *config.Config) (*NATSServer, error) {
	// Initialize NATS client
	natsClient, err := natserve.NewNatsClient(cfg)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize NATS client: %w", err)
	}

	return &NATSServer{
		Client: natsClient,
	}, nil
}

// RegisterEndpoints registers all NATS endpoints
func (s *NATSServer) MountNats() error {
	// Register health check endpoint
	if err := s.Client.AddEndpoint("health", handlers.HealthHandler); err != nil {
		return fmt.Errorf("failed to register health endpoint: %w", err)
	}

	// Register hello endpoint
	if err := s.Client.AddEndpoint("hello", handlers.HelloHandler); err != nil {
		return fmt.Errorf("failed to register hello endpoint: %w", err)
	}

	log.Println("NATS endpoints registered successfully")
	return nil
}

// Start starts the NATS server
func (s *NATSServer) Start() {
	log.Println("NATS microservice is running...")
}

// Stop shuts down the NATS server
func (s *NATSServer) Stop() {
	s.Client.Disconnect()
	log.Println("NATS microservice stopped")
}
