package models

import (
	"database/sql"
	"time"
)

type Store struct {
	ID              int64         `json:"id"`
	CompanyID       int           `json:"company_id"`
	AccessTokenID   sql.NullInt64 `json:"access_token_id"`
	AuthorizeTime   time.Time     `json:"authorize_time"`
	ExpiryTime      time.Time     `json:"expiry_time"`
	LastSynced      time.Time     `json:"last_synced"`
	Name            string        `json:"name"`
	Platform        string        `json:"platform"`
	Region          string        `json:"region"`
	DiscountCode    string        `json:"discount_code"`
	ShippingCode    string        `json:"shipping_code"`
	TransactionCode string        `json:"transaction_code"`
	VoucherCode     string        `json:"voucher_code"`
	Descriptions    string        `json:"descriptions"`
	Status          bool          `json:"status"`
}
