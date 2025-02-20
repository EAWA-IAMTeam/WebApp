package database

import (
	"database/sql"
	"log"

	_ "github.com/lib/pq" // Import PostgreSQL driver
)

// DB is a global variable for database connection
var DB *sql.DB

// InitializeDB initializes the database connection
func InitializeDB() {
	var err error
	DB, err = sql.Open("postgres", "postgres://postgresadmin:admin123@192.168.0.189:5000/ecommercedb?sslmode=disable")
	//"postgres", "postgres://postgres:postgres@192.168.11.12:5432/postgres?sslmode=disable"
	if err != nil {
		log.Fatal("Database connection error:", err)
	}

	// Test the connection
	if err := DB.Ping(); err != nil {
		log.Fatal("Database is unreachable:", err)
	}

	log.Println("Connected to PostgreSQL successfully!")
}

// sql.Open("postgres", "..."): This initializes a connection to the PostgreSQL database.
// Connection String:
//  - "postgres://postgres:postgres@192.168.11.12:5432/postgres?sslmode=disable"
//  - postgres:// → Specifies the PostgreSQL protocol.
//  - postgres:postgres → Username (postgres) and password (postgres).
//  - 192.168.11.12:5432 → IP address (192.168.11.12) and port (5432, default PostgreSQL port).
//  - /postgres → Database name (postgres).
//  - sslmode=disable → Disables SSL encryption for the connection.
