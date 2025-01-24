package main

import (
	"iop-go-sdk/iop"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

var client *iop.IopClient

func init() {
	appKey := "131165"
	appSecret := "abLdom8jDX3hgh3p23DeeJFa5XSXeFwB"

	clientOptions := iop.ClientOptions{
		APIKey:    appKey,
		APISecret: appSecret,
		Region:    "MY",
	}

	client = iop.NewClient(&clientOptions)
	client.SetAccessToken("50000001c28clcgXddQ4nzUdiEtGYDRz9hYmQxcL1d3cbc89oWqmqyaeubxzvXOK")
}

func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}

func getProducts(c *gin.Context) {
	// client.AddAPIParam("limit", "10")
	// client.AddAPIParam("offset", "0")

	getResult, err := client.Execute("/products/get", "GET", nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch products: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, getResult)
}

func main() {
	r := gin.Default()

	// Apply the CORS middleware
	r.Use(CORSMiddleware())

	r.GET("/products", getProducts)

	// Replace "0.0.0.0" with your machine's local IP address
	serverAddress := "192.168.0.240:7000" // Bind to all network interfaces

	log.Printf("Server running on http://%s", serverAddress)
	if err := r.Run(serverAddress); err != nil {
		log.Fatal("Failed to run server: ", err)
	}
}
