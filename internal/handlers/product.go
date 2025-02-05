package handlers

import (
	"auth_ecommerce/internal/models"
	"bytes"
	"database/sql"
	"fmt"
	"io"
	"log"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

// GetStockItemsByCompany handles fetching stock items by company ID
func GetStockItemsByCompany(db *sql.DB) echo.HandlerFunc {
	return func(c echo.Context) error {
		companyID, err := strconv.Atoi(c.Param("company_id"))
		if err != nil {
			log.Printf("Failed to convert company_id to int: %v", err)
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid company_id"})
		}

		query := `
            SELECT id, company_id, stock_code, stock_control, ref_price, ref_cost, weight, 
                   height, width, length, variation1, variation2, quantity, reserved_quantity,
                   platform, description, status 
            FROM stockitem 
            WHERE company_id = $1`

		rows, err := db.Query(query, companyID)
		if err != nil {
			log.Printf("Failed to query stock items: %v", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to query stock items"})
		}
		defer rows.Close()

		var stockItems []*models.StockItem
		for rows.Next() {
			var item models.StockItem
			err := rows.Scan(
				&item.ID, &item.CompanyID, &item.StockCode, &item.StockControl, &item.RefPrice,
				&item.RefCost, &item.Weight, &item.Height, &item.Width,
				&item.Length, &item.Variation1, &item.Variation2, &item.Quantity, &item.ReservedQuantity,
				&item.Platform, &item.Description, &item.Status,
			)
			if err != nil {
				log.Printf("Failed to scan stock item: %v", err)
				return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to scan stock item"})
			}
			stockItems = append(stockItems, &item)
		}
		return c.JSON(http.StatusOK, stockItems)
	}
}

// GetProducsByStore handles fetching products by store ID
func GetProducsByStore(db *sql.DB) echo.HandlerFunc {
	return func(c echo.Context) error {
		storeID, err := strconv.Atoi(c.Param("store_id"))
		if err != nil {
			log.Printf("Failed to convert store_id to int: %v", err)
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid store_id"})
		}

		query := `
            SELECT 
            	si.id, si.ref_price, si.ref_cost, si.quantity,
                sp.id, sp.price, sp.discounted_price, sp.sku, sp.currency, sp.status
            FROM storeproduct sp
            JOIN stockitem si ON sp.stock_item_id = si.id
            WHERE sp.store_id = $1`

		rows, err := db.Query(query, storeID)
		if err != nil {
			log.Printf("Failed to query products: %v", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to query products"})
		}
		defer rows.Close()

		stockItemsMap := make(map[int64]*models.MergeProduct)
		for rows.Next() {
			var (
				stockItemID       int64
				refPrice, refCost float64
				quantity          int
				storeProductID    int64
				price             float64
				discountedPrice   float64
				sku, currency     string
				status            string
			)

			err := rows.Scan(
				&stockItemID, &refPrice, &refCost, &quantity,
				&storeProductID, &price, &discountedPrice, &sku, &currency, &status,
			)

			if err != nil {
				log.Printf("Failed to scan product: %v", err)
				return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to scan product"})
			}

			if _, exists := stockItemsMap[stockItemID]; !exists {
				stockItemsMap[stockItemID] = &models.MergeProduct{
					StockItemID: stockItemID,
					RefPrice:    refPrice,
					RefCost:     refCost,
					Quantity:    quantity,
				}
			}

			storeProduct := models.StoreProduct{
				ID:              storeProductID,
				Price:           price,
				DiscountedPrice: discountedPrice,
				SKU:             sku,
				Currency:        currency,
				Status:          status,
			}

			stockItemsMap[stockItemID].StoreProducts = append(
				stockItemsMap[stockItemID].StoreProducts,
				storeProduct)
		}

		//Convert map to slice
		var result []*models.MergeProduct
		for _, item := range stockItemsMap {
			result = append(result, item)
		}
		return c.JSON(http.StatusOK, result)
	}
}

func InsertProducts(db *sql.DB) echo.HandlerFunc {
	return func(c echo.Context) error {
		// Read and log raw body
		body, err := io.ReadAll(c.Request().Body)
		if err != nil {
			log.Printf("Failed to read request body: %v", err)
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Failed to read request"})
		}
		log.Printf("Raw request body: %s", string(body))

		// Restore body for binding
		c.Request().Body = io.NopCloser(bytes.NewBuffer(body))

		var req models.ProductRequest
		if err := c.Bind(&req); err != nil {
			log.Printf("Failed to decode request body: %v", err)
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request format"})
		}

		//Validate required fields
		if req.StoreID == 0 || len(req.Products) == 0 {
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "store_id and products are required"})
		}

		result, err := insertProductBatch(db, req.StoreID, req.Products)
		if err != nil {
			log.Printf("Error inserting products: %v", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to insert products"})
		}

		if result.Inserted > 0 {
			return c.JSON(http.StatusCreated, map[string]interface{}{
				"message":    fmt.Sprintf("%d products inserted successfully", result.Inserted),
				"duplicates": result.Duplicates,
			})
		}

		statusCode := http.StatusInternalServerError
		if len(result.Duplicates) > 0 {
			statusCode = http.StatusConflict
		}

		return c.JSON(statusCode, map[string]interface{}{
			"error":      "Failed to insert products",
			"duplicates": result.Duplicates,
		})
	}
}

func insertProductBatch(db *sql.DB, storeID int64, products []models.StoreProduct) (*models.InsertResult, error) {
	result := &models.InsertResult{
		Inserted:   0,
		Duplicates: make([]string, 0),
	}

	// Start a transaction
	tx, err := db.Begin()
	if err != nil {
		return result, err
	}
	defer tx.Rollback()

	// Prepare the insert statement
	stmt, err := tx.Prepare(`
        INSERT INTO storeproduct (store_id, stock_item_id, price, discounted_price, sku, currency, status)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
    `)
	if err != nil {
		return result, err
	}
	defer stmt.Close()

	// Check for duplicates first
	for _, product := range products {
		var exists bool
		err := tx.QueryRow(
			"SELECT EXISTS(SELECT 1 FROM storeproduct WHERE stock_item_id = $1 AND sku = $2)",
			product.StockItemID, product.SKU,
		).Scan(&exists)
		if err != nil {
			return result, err
		}
		if exists {
			result.Duplicates = append(result.Duplicates, product.SKU)
			continue
		}

		// Insert the product
		res, err := stmt.Exec(
			storeID,
			product.StockItemID,
			product.Price,
			product.DiscountedPrice,
			product.SKU,
			product.Currency,
			product.Status,
		)
		if err != nil {
			return result, err
		}

		affected, err := res.RowsAffected()
		if err != nil {
			return result, err
		}
		result.Inserted += int(affected)
	}

	// Commit the transaction
	if err := tx.Commit(); err != nil {
		return result, err
	}

	return result, nil
}
