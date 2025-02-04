package modal

// Define the response structure for the product
type Product struct {
	CompanyID        int8    `json:"company_id"`
	StockCode        string  `json:"stockCode"`
	Description      string  `json:"description"`
	ReservedQuantity int8    `json:"reserved_quantity"`
	Quantity         int8    `json:"quantity"`
	Cost             float64 `json:"cost"`
	RefPrice         float64 `json:"ref_price"`
	Weight           float64 `json:"weight"`
	Height           float64 `json:"height"`
	Width            float64 `json:"width"`
	Length           float64 `json:"length"`
	Variation1       string  `json:"variation1"`
	Variation2       string  `json:"variation2"`
	Platform         string  `json:"platform"`
	MediaURL         string  `json:"media_url"`
	StockControl     bool    `json:"stock_control"`
	Status           bool    `json:"status"`
}
