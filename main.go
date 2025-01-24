package main

import (
	"fmt"
	"log"
	"os"
	"sync"
	"time"

	"auth_ecommerce/pkg/natsc"

	"github.com/joho/godotenv"
	"github.com/nats-io/nats.go"
	// "github.com/nats-io/nats.go"
)

func main() {
	// Load .env file
	err := godotenv.Load("./config/.env")
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	// Read NATS config from environment variables
	natsUrl := os.Getenv("NATS_URL")
	natsServiceName := os.Getenv("NATS_SERVICE_NAME")
	natsServiceVersion := os.Getenv("NATS_SERVICE_VERSION")
	timeout := 100 * time.Second // Set timeout to 5 seconds

	// Create NATS client configuration
	config := &natsc.NatsConfig{
		NatsUrl:            natsUrl,
		NatsServiceName:    natsServiceName,
		NatsServiceVersion: natsServiceVersion,
		Timeout:            timeout,
	}

	// Initialize NATS client
	client, err := natsc.NewNatsClient(config)
	if err != nil {
		log.Fatal(err)
	}

	// // Test Publish
	// msg := []byte("Hello, NATS!")
	// err = client.Publish("test.subject", msg)
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// fmt.Println("Message published to subject 'test.subject'")

	// // Test Subscribe
	// _, err = client.Subscribe("test.subject", func(msg *nats.Msg) {
	// 	fmt.Printf("Received message: %s\n", string(msg.Data))
	// })
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// fmt.Println("Subscribed to subject 'test.subject'")

	// Test Request (Authorization example)
	// authSubject := "auth.subject"
	// requestPayload := []byte("test auth request")

	// authorized, err := client.Authorize(authSubject, requestPayload)
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// if authorized {
	// 	fmt.Println("Authorization successful")
	// } else {
	// 	fmt.Println("Authorization failed")
	// }

	// Test Disconnect
	var wg sync.WaitGroup
	wg.Add(1)

	// Test Subscribe
	_, err = client.Subscribe("test.subject", func(msg *nats.Msg) {
		fmt.Printf("Received message: %s\n", string(msg.Data))
		wg.Done()
	})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Subscribed to subject 'test.subject'")

	// Ensure the subscription is ready
	time.Sleep(1 * time.Second)

	// Publish a message
	err = client.Publish("test.subject", []byte("Hello, NATS!"))
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Message published to subject 'test.subject'")

	// Wait for the message to be received
	wg.Wait()

	client.Disconnect()
}
