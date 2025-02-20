package handler

import (
	"encoding/json"
	"log"
	"net/http"
	"otp_login/invite_code_service/database"
	"otp_login/invite_code_service/modal"

	"github.com/labstack/echo/v4"
)

func SaveUser(c echo.Context) error {
	var user modal.User
	if err := json.NewDecoder(c.Request().Body).Decode(&user); err != nil {
		log.Println("Error decoding JSON:", err) // Log the error
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid JSON"})
	}

	tx, err := database.DB.Begin()
	if err != nil {
		log.Println("Error starting transaction:", err) // Log the error
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Database error"})
	}
	defer tx.Rollback()

	// Prepare the query
	_, err = tx.Exec(
		`INSERT INTO "User" (id, company_id, permission, email, address, first_name, last_name, nationality, role, city, gender, phone, status, zipcode) 
		VALUES ($1, $2::json, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) 
		ON CONFLICT (email) DO NOTHING`,
		1,
		2,
		json.RawMessage(`{}`), // Correctly passing an empty JSON object
		user.Email,
		"Address 11",
		user.FirstName,
		user.LastName,
		"Nationality 11",
		"Role 0",
		"City 11",
		"Female",
		"123456",
		true,
		"ZIP1011",
	)

	if err != nil {
		log.Println("Error executing query:", err) // Log the error
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Database insert error", "details": err.Error()})
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		log.Println("Error committing transaction:", err) // Log the error
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Transaction commit failed"})
	}

	// Success response
	return c.JSON(http.StatusOK, map[string]string{"message": "User saved successfully"})
}
