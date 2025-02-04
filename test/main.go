package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	natserve "auth_ecommerce/pkg/natserve"

	"github.com/nats-io/nats.go/micro"
)

func main() {
	// Configuration for NATS client
	config := &natserve.Config{
		NatsUrl:            "nats://192.168.0.151:4222", // Connect to local NATS server
		NatsServiceName:    "TestService",
		NatsServiceVersion: "1.0.0",
		Timeout:            5 * time.Second,
	}

	// Create a new NATS client
	client, err := natserve.NewNatsClient(config)
	if err != nil {
		log.Fatalf("Failed to create NATS client: %v", err)
	}
	defer client.Disconnect()

	// Add a simple health check endpoint
	err = client.AddEndpoint("health", micro.HandlerFunc(func(r micro.Request) {
		log.Println("Health check requested")
		r.Respond([]byte(`{"status": "ok"}`))
	}), micro.WithEndpointMetadata(map[string]string{"type": "healthcheck"}))
	if err != nil {
		log.Fatalf("Failed to add health endpoint: %v", err)
	}

	// Create a group for API endpoints
	apiGroup := client.AddGroup("api.v1")

	// Add an endpoint to the group
	err = apiGroup.AddEndpoint("hello", micro.HandlerFunc(func(r micro.Request) {
		log.Println("Hello endpoint requested")
		r.Respond([]byte(`{"message": "Hello, world!"}`))
	}))
	if err != nil {
		log.Fatalf("Failed to add hello endpoint: %v", err)
	}

	log.Println("Service is running. Press Ctrl+C to stop.")

	// Keep the service running until interrupted
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	<-sigChan
	log.Println("Shutting down...")
}
