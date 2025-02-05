package main

// import (
// 	"log"
// 	"os"
// 	"os/signal"
// 	"syscall"

// 	"auth_ecommerce/internal/config"
// 	"auth_ecommerce/internal/handlers"
// 	"auth_ecommerce/pkg/natserve"
// )

// func main() {
// 	// Load configuration
// 	env := config.LoadConfig()

// 	// Initialize NATS client
// 	natsClient, err := natserve.NewNatsClient(env)
// 	if err != nil {
// 		log.Fatalf("Error initializing NATS client: %v", err)
// 	}

// 	defer natsClient.Disconnect()

// 	// Register handlers
// 	err = natsClient.AddEndpoint("health", handlers.HealthHandler)
// 	if err != nil {
// 		log.Fatalf("Failed to register health check endpoint: %v", err)
// 	}
// 	err = natsClient.AddEndpoint("hello", handlers.HelloHandler)
// 	if err != nil {
// 		log.Fatalf("Failed to register hello world endpoint: %v", err)
// 	}

// 	log.Println("NATS microservice is running...")

// 	// Graceful shutdown handling
// 	sigChan := make(chan os.Signal, 1)
// 	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
// 	<-sigChan

// 	log.Println("Shutting down NATS microservice...")
// }
