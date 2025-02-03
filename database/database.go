package database

import (
	"database/sql"
	"fmt"
)

func ConnectDB() (*sql.DB, error) {
	connStr := "host=192.168.0.235 user=postgres password=postgres dbname=postgres port=5432 sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, fmt.Errorf("error opening db: %v", err)
	}
	return db, nil
}
