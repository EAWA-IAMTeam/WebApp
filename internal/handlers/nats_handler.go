package handlers

import (
	"log"

	"github.com/nats-io/nats.go/micro"
)

// HealthHandler responds with a health check message
var HealthHandler = micro.HandlerFunc(func(r micro.Request) {
	log.Println("Health check requested")
	r.Respond([]byte(`{"status": "ok"}`))
})

// HelloHandler responds with a simple greeting
var HelloHandler = micro.HandlerFunc(func(r micro.Request) {
	log.Println("Hello endpoint requested")
	r.Respond([]byte(`{"message": "Hello, world!"}`))
})
