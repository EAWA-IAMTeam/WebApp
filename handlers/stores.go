package handlers

import (
	"auth_ecommerce/models"
	"database/sql"
	"log"
	"net/http"

	"github.com/labstack/echo/v4"
)

func GetStores(db *sql.DB) echo.HandlerFunc {
	return func(c echo.Context) error {
		rows, err := db.Query("SELECT * FROM store")
		if err != nil {
			log.Fatalf("Failed to query stores: %v", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to query stores"})
		}
		defer rows.Close()

		stores := []*models.Store{}
		for rows.Next() {
			var store models.Store
			if err := rows.Scan(&store.ID, &store.CompanyID, &store.AccessTokenID, &store.AuthorizeTime, &store.ExpiryTime, &store.LastSynced, &store.Name, &store.Platform, &store.Region, &store.DiscountCode, &store.ShippingCode, &store.TransactionCode, &store.VoucherCode, &store.Descriptions, &store.Status); err != nil {
				log.Printf("Failed to scan store: %v", err)
				return c.JSON(http.StatusInternalServerError, map[string]string{"message": "Failed to scan store"})
			}
			stores = append(stores, &store)
		}
		return c.JSON(http.StatusOK, stores)
	}
}

// CreateStoreHandler handles the creation of a new store
func CreateStoreHandler(db *sql.DB) echo.HandlerFunc {
	return func(c echo.Context) error {
		store := new(models.Store)

		// Decode the request body into the store struct
		if err := c.Bind(store); err != nil {
			log.Printf("Failed to decode request body: %v", err)
			return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid request payload"})
		}

		// Insert the store into the database
		query := `INSERT INTO store (company_id, access_token_id, name, platform, region, discount_code, shipping_code, transaction_code, voucher_code, descriptions, status)
                  VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING id`
		err := db.QueryRow(query, store.CompanyID, store.AccessTokenID, store.Name, store.Platform, store.Region, store.DiscountCode, store.ShippingCode, store.TransactionCode, store.VoucherCode, store.Descriptions, store.Status).Scan(&store.ID)
		if err != nil {
			log.Printf("Failed to insert store: %v", err)
			return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
		}

		// Respond with the created store
		return c.JSON(http.StatusCreated, store)
	}
}
