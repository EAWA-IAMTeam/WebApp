package main

import (
	"backend/database"
	"backend/handler"
	"fmt"
	"log"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {

	database.InitializeDB()

	// Initialize Echo instance
	e := echo.New()

	// Enable CORS with middleware
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"http://localhost:8020"}, // Replace with the URL of your frontend
		AllowMethods: []string{echo.GET, echo.POST},     // Allow only GET and POST methods
	}))

	// Set up the POST route for token exchange
	e.POST("/products", handler.SaveProducts)

	// Start the server on port 8010
	fmt.Println("Server is running on port 8013")
	if err := e.Start(":8013"); err != nil {
		log.Fatalf("Error starting server: %v", err)
	}

}
