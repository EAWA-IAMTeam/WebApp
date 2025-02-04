package client

import (
	"auth_ecommerce/internal/iop"
	"auth_ecommerce/internal/models"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/labstack/echo/v4"
)

// Helper functions
func getStoreSkus(db *sql.DB, storeID string) (map[string]bool, error) {
	query := "SELECT sku FROM storeproduct WHERE store_id = $1"
	rows, err := db.Query(query, storeID)
	if err != nil {
		return nil, fmt.Errorf("failed to query database: %v", err)
	}
	defer rows.Close()

	skus := make(map[string]bool)
	for rows.Next() {
		var sku string
		if err := rows.Scan(&sku); err != nil {
			return nil, fmt.Errorf("failed to scan row: %v", err)
		}
		skus[sku] = true
	}

	return skus, rows.Err()
}

func GetFilteredProducts(db *sql.DB, client *iop.IopClient) echo.HandlerFunc {
	return func(c echo.Context) error {
		// 1. Get store_id and validate
		storeID := c.Param("store_id")
		if storeID == "" {
			return c.JSON(http.StatusBadRequest, map[string]string{
				"message": "store_id is required",
			})
		}

		// 2. Get existing SKUs from database
		skusToRemove, err := getStoreSkus(db, storeID)
		if err != nil {
			log.Printf("Failed to fetch SKUs: %v", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{
				"message": "Failed to retrieve SKU list",
			})
		}

		// 3. Call API and get products
		resp, err := client.Execute("/products/get", "GET", nil)
		if err != nil {
			log.Printf("Failed to fetch products from API: %v", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{
				"message": "Failed to fetch products",
			})
		}

		// 4. Process API response
		products, err := processApiResponse(resp, skusToRemove)
		if err != nil {
			log.Printf("Failed to process API response: %v", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{
				"message": "Failed to process response",
			})
		}

		return c.JSON(http.StatusOK, products)
	}
}

func processApiResponse(resp interface{}, skusToRemove map[string]bool) (map[string]interface{}, error) {
	// Convert response to JSON
	responseBytes, err := json.Marshal(resp)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal response: %v", err)
	}

	var apiResponse models.ApiResponse
	if err := json.Unmarshal(responseBytes, &apiResponse); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %v", err)
	}

	var unmappedProducts, mappedProducts []models.Product

	for _, product := range apiResponse.Data.Products {
		var remainingSkus, removedSkus []models.Sku

		for _, sku := range product.Skus {
			if skusToRemove[sku.ShopSku] {
				removedSkus = append(removedSkus, sku)
			} else {
				remainingSkus = append(remainingSkus, sku)
			}
		}

		if len(remainingSkus) > 0 {
			product.Skus = remainingSkus
			unmappedProducts = append(unmappedProducts, product)
		}
		if len(removedSkus) > 0 {
			productCopy := product
			productCopy.Skus = removedSkus
			mappedProducts = append(mappedProducts, productCopy)
		}
	}

	return map[string]interface{}{
		"unmapped_products": unmappedProducts,
		"mapped_products":   mappedProducts,
	}, nil
}
