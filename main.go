package main

import (
	"auth_ecommerce/database"
	"auth_ecommerce/internal/client"
	"auth_ecommerce/internal/config"
	"auth_ecommerce/internal/handlers"
	"auth_ecommerce/internal/iop"
	"auth_ecommerce/internal/middleware"
	"fmt"
	"log"

	"github.com/labstack/echo/v4"
	_ "github.com/lib/pq"
)

// var users = map[string]*User{}

func main() {
	// Load configuration
	env := config.LoadConfig()

	// Connect to the database
	db, err := database.ConnectDB()
	if err != nil {
		log.Fatalf("Failed to connect to the database: %v", err)
	}

	// Test the connection
	err = db.Ping()
	if err != nil {
		log.Fatalf("Failed to connect to the database: %v", err)
	} else {
		fmt.Println("Connected to the database successfully!")
	}

	defer db.Close()

	// Initialize IOP client
	clientOptions := iop.ClientOptions{
		APIKey:    "131165",
		APISecret: env.APISecret,
		Region:    "MY",
	}
	iopClient := iop.NewClient(&clientOptions)
	iopClient.SetAccessToken(env.AccessToken)

	// Create a new echo instance
	e := echo.New()

	// Middleware
	e.Use(middleware.CORSConfig())

	//Define routes
	e.GET("/stores", handlers.GetStores(db))
	e.POST("/stores", handlers.CreateStoreHandler(db))
	e.GET("/products/company/:company_id", handlers.GetStockItemsByCompany(db))
	e.GET("/products/store/:store_id", handlers.GetProducsByStore(db))
	e.POST("/products", handlers.InsertProducts(db))
	e.GET("/lazada/:store_id", client.GetFilteredProducts(db, iopClient))

	// Start the server
	e.Logger.Fatal(e.Start(":8100"))
}
