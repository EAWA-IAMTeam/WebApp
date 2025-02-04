package natserve

import (
	"fmt"
	"log"

	"auth_ecommerce/internal/config"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/micro"
)

// Client interface defines NATS operations
type Client interface {
	AddEndpoint(name string, handler micro.Handler, opts ...micro.EndpointOpt) error
	AddGroup(name string, opts ...micro.GroupOpt) micro.Group
	Disconnect()
}

// natsClient implements the Client interface
type natsClient struct {
	Conn    *nats.Conn
	Service micro.Service
}

// NewNatsClient initializes a NATS client
func NewNatsClient(cfg *config.NatsConfig) (Client, error) {
	log.Println("Connecting to NATS...")

	nc, err := nats.Connect(cfg.URL())
	if err != nil {
		return nil, fmt.Errorf("failed to connect to NATS: %w", err)
	}

	srv, err := micro.AddService(nc, micro.Config{
		Name:    cfg.Name(),
		Version: cfg.Version(),
	})
	if err != nil {
		nc.Close()
		return nil, fmt.Errorf("failed to add NATS service: %w", err)
	}

	log.Println("Connected to NATS successfully.")
	return &natsClient{Conn: nc, Service: srv}, nil
}

// AddEndpoint registers an endpoint
func (c *natsClient) AddEndpoint(name string, handler micro.Handler, opts ...micro.EndpointOpt) error {
	return c.Service.AddEndpoint(name, handler, opts...)
}

// AddGroup registers a new group
func (c *natsClient) AddGroup(name string, opts ...micro.GroupOpt) micro.Group {
	return c.Service.AddGroup(name, opts...)
}

// Disconnect closes the connection to NATS
func (c *natsClient) Disconnect() {
	log.Println("Disconnecting from NATS...")
	c.Conn.Close()
	log.Println("Disconnected from NATS.")
}
