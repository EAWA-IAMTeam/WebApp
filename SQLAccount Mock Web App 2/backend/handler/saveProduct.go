package handler

import (
	"backend/database"
	"backend/modal"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/labstack/echo/v4"
)

func SaveProducts(c echo.Context) error {
	var products []modal.Product
	if err := json.NewDecoder(c.Request().Body).Decode(&products); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid JSON"})
	}

	tx, err := database.DB.Begin()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Database error"})
	}
	defer tx.Rollback()

	for _, product := range products {
		_, err := tx.Exec(
			"INSERT INTO stockitem (id, company_id, reserved_quantity, quantity, ref_cost, ref_price, weight, height, width, length, stock_code, variation1, variation2, description, platform, media_url, stock_control, status) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18) ON CONFLICT (stock_code) DO NOTHING",
			product.StockCode,
			2,
			15,
			product.Quantity,
			product.Cost,
			1500,
			10,
			8,
			5,
			20,
			product.StockCode,
			"Variation 12",
			"Variation B 12",
			product.Description,
			"Platform 2",
			"{}",
			true,
			true,
		)
		if err != nil {
			fmt.Println("Error inserting product: %v", err) // log the actual error
			return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Database insert error"})
		}
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Transaction commit failed"})
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "Products saved successfully"})
}
