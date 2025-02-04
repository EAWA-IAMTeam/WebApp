package handlers

import (
	"auth_ecommerce/internal/models"
	"database/sql"
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
