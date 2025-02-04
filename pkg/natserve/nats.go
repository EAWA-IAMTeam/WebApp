package natserve

import (
	"fmt"
	"time"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/micro"
)

// Config holds NATS connection and service configuration
type Config struct {
	NatsUrl            string
	NatsServiceName    string
	NatsServiceVersion string
	Timeout            time.Duration
}

// Client interface for NATS operations
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

// NewNatsClient creates a new NATS client with the provided configuration
func NewNatsClient(config *Config) (Client, error) {
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
	}, nil
}

// AddEndpoint adds an endpoint to the service
func (c *natsClient) AddEndpoint(name string, handler micro.Handler, opts ...micro.EndpointOpt) error {
	return c.Service.AddEndpoint(name, handler, opts...)
}

// AddGroup adds a group to the service
func (c *natsClient) AddGroup(name string, opts ...micro.GroupOpt) micro.Group {
	return c.Service.AddGroup(name, opts...)
}

// Disconnect closes the connection to NATS
func (c *natsClient) Disconnect() {
	fmt.Println("disconnecting nats..")
	c.Conn.Close()
	fmt.Println("disconnected nats")
}
