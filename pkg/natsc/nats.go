package natsc

import (
	"errors"
	"fmt"
	"time"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/micro"
)

// NatsConfig holds the configuration for the NATS client
type NatsConfig struct {
	NatsUrl            string
	NatsServiceName    string
	NatsServiceVersion string
	Timeout            time.Duration
}

// NatsClient is an interface for the NATS client
type NatsClient interface {
	Publish(subject string, msg []byte) error
	Subscribe(subject string, handler func(msg *nats.Msg)) (*nats.Subscription, error)
	Request(subject string, msg []byte) (*nats.Msg, error)
	// Authorize(authSubject string, requestPayload []byte) (bool, error)
	Disconnect()
}

// natsClient is the implementation of the NatsClient interface
type natsClient struct {
	Conn    *nats.Conn
	Service micro.Service
	Timeout time.Duration
}

// Publisher send a message to the specified subject
func (n *natsClient) Publish(subject string, msg []byte) error {
	return n.Conn.Publish(subject, msg)
}

// Subscribe sets up a subscription to the specified subject
func (n *natsClient) Subscribe(subject string, handler func(msg *nats.Msg)) (*nats.Subscription, error) {
	return n.Conn.Subscribe(subject, handler)
}

// Request sends a request and waits for a response
func (n *natsClient) Request(subject string, msg []byte) (*nats.Msg, error) {
	return n.Conn.Request(subject, msg, n.Timeout)
}

// Authorize sends an authorization request and returns the result.
// func (n *natsClient) Authorize(authSubject string, requestPayload []byte) (bool, error) {
// 	response, err := n.Request(authSubject, requestPayload)
// 	if err != nil {
// 		return false, err
// 	}
// 	return string(response.Data) == "authorized", nil
// }

// Disconnect closes the connection to NATS.
func (n *natsClient) Disconnect() {
	fmt.Println("disconnecting nats..")
	n.Conn.Close()
	fmt.Println("disconnected nats")
}

// validateConfig checks if the provided configuration is valid.
func validateConfig(config *NatsConfig) error {
	if config.NatsUrl == "" {
		return errors.New("NATS URL cannot be empty")
	}
	if config.NatsServiceName == "" {
		return errors.New("NATS Service Name cannot be empty")
	}
	if config.Timeout <= 0 {
		return errors.New("Timeout must be greater than zero")
	}
	return nil
}

// NewNatsClient creates a new NATS client with the provided configuration.
func NewNatsClient(config *NatsConfig) (NatsClient, error) {
	if err := validateConfig(config); err != nil {
		return nil, err
	}

	fmt.Println("connecting to nats..")
	nc, err := nats.Connect(config.NatsUrl)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to NATS: %w", err)
	}

	srv, err := micro.AddService(nc, micro.Config{
		Name:    config.NatsServiceName,
		Version: config.NatsServiceVersion,
	})
	if err != nil {
		nc.Close()
		return nil, fmt.Errorf("failed to add NATS service: %w", err)
	}

	fmt.Println("connected to nats")
	return &natsClient{
		Conn:    nc,
		Service: srv,
		Timeout: config.Timeout,
	}, nil
}
