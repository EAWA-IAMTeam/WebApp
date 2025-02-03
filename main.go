// package main

// import (
// 	"auth_ecommerce/middleware"
// 	"auth_ecommerce/models"
// 	"net/http"

// 	"github.com/labstack/echo/v4"
// )

// func main() {
// 	e := echo.New()

// 	//Public endpoint
// 	e.POST("/login", func(c echo.Context) error {
// 		username := c.FormValue("username")
// 		role := c.FormValue("role")

// 		if username == "" || role == "" {
// 			return c.JSON(http.StatusBadRequest, map[string]string{"message": "username and role are required"})
// 		}

// 		token, err := middleware.GenerateToken(username, role)
// 		if err != nil {
// 			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to generate token"})
// 		}

// 		return c.JSON(http.StatusOK, map[string]string{"token": token})
// 	})

// 	//Protected endpoint
// 	e.GET("/protected", func(c echo.Context) error {
// 		user := c.Get("user").(*models.Claims)
// 		return c.JSON(http.StatusOK, map[string]string{
// 			"user": user.Username,
// 			"role": user.Role,
// 		})
// 	}, middleware.AuthMiddleware)

//		e.Logger.Fatal(e.Start(":8200"))
//	}
package main

import (
	"auth_ecommerce/database"
	"auth_ecommerce/handlers"
	"fmt"
	"log"

	"auth_ecommerce/middleware"

	"github.com/labstack/echo/v4"
	_ "github.com/lib/pq"
)

// var users = map[string]*User{}

func main() {
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

	// Create a new echo instance
	e := echo.New()

	// Middleware
	e.Use(middleware.CORSConfig())

	e.GET("/stores", handlers.GetStores(db))
	e.POST("/stores", handlers.CreateStoreHandler(db))
	//Define routes

	// Start the server
	e.Logger.Fatal(e.Start(":8100"))
}
