package models

// import (
// 	"bytes"
// 	"encoding/json"
// 	"fmt"
// 	"io/ioutil"
// 	"net/http"
// )

// type Product struct {
// 	ID          int     `json:"id"`
// 	Name        string  `json:"name"`
// 	Description string  `json:"description"`
// 	Platform    string  `json:"platform"`
// 	Stock       int     `json:"stock"`
// 	SKU         string  `json:"sku"`
// 	Currency    string  `json:"currency"`
// 	Price       float64 `json:"price"`
// 	Status      string  `json:"status"`
// 	CreatedAt   string  `json:"created_at"`
// 	UpdatedAt   string  `json:"updated_at"`
// }

// type ShopeeAuthRequest struct {
// 	Sign          string `json:"sign"`
// 	PartnerID     string `json:"partner_id"`
// 	Timestamp     int64  `json:"timestamp"`
// 	Code          string `json:"code"`
// 	ShopID        string `json:"shop_id,omitempty"`         // Optional
// 	MainAccountID string `json:"main_account_id,omitempty"` // Optional
// }

// type ShopeeAuthResponse struct {
// 	ID             string   `json:"id"`
// 	RequestID      string   `json:"request_id"`
// 	Error          string   `json:"error"`
// 	RefreshToken   string   `json:"refresh_token"`
// 	AccessToken    string   `json:"access_token"`
// 	ExpireIn       string   `json:"expire_in"`
// 	Message        string   `json:"message"`
// 	MerchantIDList []string `json:"merchant_id_list,omitempty"`
// 	ShopIDList     []string `json:"shop_id_list,omitempty"`
// }

// const baseURL = "http://192.168.0.73:5000/api"

// func getProducts() {
// 	resp, err := http.Get(baseURL + "/products")
// 	if err != nil {
// 		fmt.Println("Error fetching products:", err)
// 		return
// 	}
// 	defer resp.Body.Close()

// 	body, err := ioutil.ReadAll(resp.Body)
// 	if err != nil {
// 		fmt.Println("Error reading response body:", err)
// 		return
// 	}

// 	var products []Product
// 	err = json.Unmarshal(body, &products)
// 	if err != nil {
// 		fmt.Println("Error unmarshalling JSON:", err)
// 		return
// 	}

// 	fmt.Println("Products:")
// 	for _, product := range products {
// 		fmt.Printf("%+v\n", product)
// 	}
// }

// func getProductByID(productID int) {
// 	resp, err := http.Get(fmt.Sprintf("%s/products/%d", baseURL, productID))
// 	if err != nil {
// 		fmt.Println("Error fetching product by ID:", err)
// 		return
// 	}
// 	defer resp.Body.Close()

// 	body, err := ioutil.ReadAll(resp.Body)
// 	if err != nil {
// 		fmt.Println("Error reading response body:", err)
// 		return
// 	}

// 	if resp.StatusCode == http.StatusNotFound {
// 		fmt.Println("Product not found.")
// 		return
// 	}

// 	var product Product
// 	err = json.Unmarshal(body, &product)
// 	if err != nil {
// 		fmt.Println("Error unmarshalling JSON:", err)
// 		return
// 	}

// 	fmt.Printf("Product Details: %+v\n", product)
// }

// func authenticateShopee() {
// 	reqBody := ShopeeAuthRequest{
// 		Sign:      "signature_example",
// 		PartnerID: "partner_123",
// 		Timestamp: 1674518400,
// 		Code:      "auth_code_example",
// 		ShopID:    "shop_1",
// 	}

// 	jsonData, err := json.Marshal(reqBody)
// 	if err != nil {
// 		fmt.Println("Error marshalling request body:", err)
// 		return
// 	}

// 	resp, err := http.Post(baseURL+"/shopee_auth", "application/json", bytes.NewBuffer(jsonData))
// 	if err != nil {
// 		fmt.Println("Error making POST request:", err)
// 		return
// 	}
// 	defer resp.Body.Close()

// 	body, err := ioutil.ReadAll(resp.Body)
// 	if err != nil {
// 		fmt.Println("Error reading response body:", err)
// 		return
// 	}

// 	var authResponse ShopeeAuthResponse
// 	err = json.Unmarshal(body, &authResponse)
// 	if err != nil {
// 		fmt.Println("Error unmarshalling JSON:", err)
// 		return
// 	}

// 	fmt.Printf("Shopee Auth Response: %+v\n", authResponse)
// }

// func authenticateShopeeWithMainAccountID() {
// 	reqBody := ShopeeAuthRequest{
// 		Sign:          "signature_example",
// 		PartnerID:     "partner_123",
// 		Timestamp:     1674518400,
// 		Code:          "auth_code_example",
// 		MainAccountID: "main_account_123",
// 	}

// 	jsonData, err := json.Marshal(reqBody)
// 	if err != nil {
// 		fmt.Println("Error marshalling request body:", err)
// 		return
// 	}

// 	resp, err := http.Post(baseURL+"/shopee_auth", "application/json", bytes.NewBuffer(jsonData))
// 	if err != nil {
// 		fmt.Println("Error making POST request:", err)
// 		return
// 	}
// 	defer resp.Body.Close()

// 	body, err := ioutil.ReadAll(resp.Body)
// 	if err != nil {
// 		fmt.Println("Error reading response body:", err)
// 		return
// 	}

// 	var authResponse ShopeeAuthResponse
// 	err = json.Unmarshal(body, &authResponse)
// 	if err != nil {
// 		fmt.Println("Error unmarshalling JSON:", err)
// 		return
// 	}

// 	fmt.Printf("Shopee Auth Response with Main Account ID: %+v\n", authResponse)
// }

// func main() {
// 	fmt.Println("Calling Flask APIs from Go")

// 	fmt.Println("\nFetching all products...")
// 	getProducts()

// 	fmt.Println("\nFetching product with ID 1...")
// 	getProductByID(1)

// 	fmt.Println("\nAuthenticating with Shopee using Shop ID...")
// 	authenticateShopee()

// 	fmt.Println("\nAuthenticating with Shopee using Main Account ID...")
// 	authenticateShopeeWithMainAccountID()
// }
