// package main

// import (
// 	"crypto/aes"
// 	"crypto/cipher"
// 	"crypto/rand"
// 	"encoding/base64"
// 	"encoding/json"
// 	"errors"
// 	"fmt"
// 	"io"
// 	"net/http"
// 	"os"
// 	"strconv"
// 	"strings"
// 	"time"

// 	"github.com/joho/godotenv"
// )

// var aesKey []byte

// func init() {
// 	// Load environment variables from the correct .env file location
// 	err := godotenv.Load("../scripts/.env") // Update path to point to scripts folder
// 	if err != nil {
// 		panic("Error loading .env file")
// 	}

// 	// Decode AES_KEY from Base64
// 	aesKeyDecoded, err := base64.StdEncoding.DecodeString(getEnv("AES_KEY", ""))
// 	if err != nil {
// 		panic("Invalid AES_KEY in .env file")
// 	}
// 	aesKey = aesKeyDecoded
// }

// func getEnv(key, fallback string) string {
// 	if value, ok := os.LookupEnv(key); ok {
// 		return value
// 	}
// 	return fallback
// }

// // Encrypt static data
// func encryptData(groupID, subgroupID string) (string, error) {
// 	expiration := time.Now().Add(24 * time.Hour).Unix()
// 	plainText := fmt.Sprintf("%s|%s|%d", groupID, subgroupID, expiration)

// 	block, err := aes.NewCipher(aesKey)
// 	if err != nil {
// 		return "", err
// 	}

// 	paddedText := pad([]byte(plainText), aes.BlockSize)
// 	cipherText := make([]byte, aes.BlockSize+len(paddedText))
// 	iv := cipherText[:aes.BlockSize]
// 	if _, err := io.ReadFull(rand.Reader, iv); err != nil {
// 		return "", err
// 	}

// 	mode := cipher.NewCBCEncrypter(block, iv)
// 	mode.CryptBlocks(cipherText[aes.BlockSize:], paddedText)

// 	return base64.StdEncoding.EncodeToString(cipherText), nil
// }

// // Decrypt static data
// func decryptData(encryptedCode string) (string, string, error) {
// 	cipherText, err := base64.StdEncoding.DecodeString(encryptedCode)
// 	if err != nil {
// 		return "", "", err
// 	}

// 	block, err := aes.NewCipher(aesKey)
// 	if err != nil {
// 		return "", "", err
// 	}

// 	if len(cipherText) < aes.BlockSize {
// 		return "", "", errors.New("cipherText too short")
// 	}

// 	iv := cipherText[:aes.BlockSize]
// 	cipherText = cipherText[aes.BlockSize:]
// 	mode := cipher.NewCBCDecrypter(block, iv)

// 	paddedText := make([]byte, len(cipherText))
// 	mode.CryptBlocks(paddedText, cipherText)

// 	plainText, err := unpad(paddedText, aes.BlockSize)
// 	if err != nil {
// 		return "", "", err
// 	}

// 	parts := strings.Split(string(plainText), "|")
// 	if len(parts) != 3 {
// 		return "", "", errors.New("invalid data format")
// 	}

// 	groupID := parts[0]
// 	subgroupID := parts[1]
// 	expiration, err := strconv.ParseInt(parts[2], 10, 64)
// 	if err != nil || time.Now().Unix() > expiration {
// 		return "", "", errors.New("code expired or invalid")
// 	}

// 	return groupID, subgroupID, nil
// }

// func pad(data []byte, blockSize int) []byte {
// 	padding := blockSize - len(data)%blockSize
// 	padText := make([]byte, padding)
// 	for i := range padText {
// 		padText[i] = byte(padding)
// 	}
// 	return append(data, padText...)
// }

// func unpad(data []byte, blockSize int) ([]byte, error) {
// 	length := len(data)
// 	padding := int(data[length-1])
// 	if padding > blockSize || padding == 0 {
// 		return nil, errors.New("invalid padding")
// 	}
// 	return data[:length-padding], nil
// }

// func encryptHandler(w http.ResponseWriter, r *http.Request) {
// 	if r.Method != http.MethodPost {
// 		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
// 		return
// 	}

// 	groupID := r.FormValue("groupId")
// 	subgroupID := r.FormValue("subgroupId")
// 	if groupID == "" || subgroupID == "" {
// 		http.Error(w, "Missing parameters", http.StatusBadRequest)
// 		return
// 	}

// 	encrypted, err := encryptData(groupID, subgroupID)
// 	if err != nil {
// 		http.Error(w, "Encryption failed: "+err.Error(), http.StatusInternalServerError)
// 		return
// 	}

// 	fmt.Fprint(w, encrypted)
// }

// func verifyHandler(w http.ResponseWriter, r *http.Request) {
// 	if r.Method != http.MethodPost {
// 		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
// 		return
// 	}

// 	encryptedCode := r.FormValue("encryptedCode")
// 	groupID, subgroupID, err := decryptData(encryptedCode)
// 	if err != nil {
// 		http.Error(w, err.Error(), http.StatusBadRequest)
// 		return
// 	}

// 	response := map[string]string{
// 		"groupId":    groupID,
// 		"subgroupId": subgroupID,
// 	}
// 	w.Header().Set("Content-Type", "application/json")
// 	json.NewEncoder(w).Encode(response)
// }

// func getKeycloakConfigHandler(w http.ResponseWriter, r *http.Request) {
// 	if r.Method != http.MethodGet {
// 		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
// 		return
// 	}

// 	// Load the environment variables from the .env file
// 	clientID := getEnv("KEYCLOAK_CLIENT_ID", "")
// 	clientSecret := getEnv("KEYCLOAK_CLIENT_SECRET", "")

// 	if clientID == "" || clientSecret == "" {
// 		http.Error(w, "Missing Keycloak configuration", http.StatusInternalServerError)
// 		return
// 	}

// 	// Prepare the response
// 	response := map[string]string{
// 		"KCID":     clientID,
// 		"KCSecret": clientSecret,
// 	}

// 	w.Header().Set("Content-Type", "application/json")
// 	json.NewEncoder(w).Encode(response)
// }

// // SetPersistentCookies sets a persistent cookie
// func setPersistentCookies(w http.ResponseWriter, r *http.Request) {
// 	cookieName := r.URL.Query().Get("name")
// 	cookieValue := r.URL.Query().Get("value")
// 	if cookieName == "" || cookieValue == "" {
// 		http.Error(w, "Missing cookie name or value", http.StatusBadRequest)
// 		return
// 	}

// 	// Set cookie with a long expiration time
// 	http.SetCookie(w, &http.Cookie{
// 		Name:  cookieName,
// 		Value: cookieValue,
// 		Path:  "/",
// 		// Expires:  time.Date(9999, 12, 31, 23, 59, 59, 0, time.UTC), // Expiry date set to year 9999
// 		MaxAge:   34560000, // 400 days
// 		Secure:   true,     // Only send over HTTPS
// 		HttpOnly: true,     // Prevent JavaScript access
// 		SameSite: http.SameSiteNoneMode,
// 	})
// 	w.WriteHeader(http.StatusOK)
// }

// // GetCookies retrieves a cookie value by its name
// func getCookies(w http.ResponseWriter, r *http.Request) {
// 	cookieName := r.URL.Query().Get("name")
// 	if cookieName == "" {
// 		http.Error(w, "Missing cookie name", http.StatusBadRequest)
// 		return
// 	}

// 	cookie, err := r.Cookie(cookieName)
// 	if err != nil {
// 		http.Error(w, "Cookie not found", http.StatusNotFound)
// 		return
// 	}

// 	w.Write([]byte(cookie.Value))
// }

// // DeleteCookies deletes a cookie
// func deleteCookies(w http.ResponseWriter, r *http.Request) {
// 	cookieName := r.URL.Query().Get("name")
// 	if cookieName == "" {
// 		http.Error(w, "Missing cookie name", http.StatusBadRequest)
// 		return
// 	}

// 	http.SetCookie(w, &http.Cookie{
// 		Name:   cookieName,
// 		Value:  "",
// 		Path:   "/",
// 		MaxAge: -1, // Expire immediately
// 	})
// 	w.WriteHeader(http.StatusOK)
// }

// func main() {
// 	// http.HandleFunc("/encrypt", encryptHandler)
// 	// http.HandleFunc("/verify", verifyHandler)
// 	http.HandleFunc("/keycloak-config", getKeycloakConfigHandler)
// 	http.HandleFunc("/setCookie", setPersistentCookies)
// 	http.HandleFunc("/getCookie", getCookies)
// 	http.HandleFunc("/deleteCookie", deleteCookies)

// 	fmt.Println("Server running at http://localhost:3002")
// 	http.ListenAndServe(":3002", nil)
// }

package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"otp_login/invite_code_service/handler"
	"strconv"
	"strings"
	"time"

	"github.com/joho/godotenv"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

var aesKey []byte

func init() {
	err := godotenv.Load("../scripts/.env")
	if err != nil {
		panic("Error loading .env file")
	}

	aesKeyDecoded, err := base64.StdEncoding.DecodeString(getEnv("AES_KEY", ""))
	if err != nil {
		panic("Invalid AES_KEY in .env file")
	}
	aesKey = aesKeyDecoded
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

// Encryption Functions
func encryptData(groupID, subgroupID string) (string, error) {
	expiration := time.Now().Add(24 * time.Hour).Unix()
	plainText := fmt.Sprintf("%s|%s|%d", groupID, subgroupID, expiration)

	block, err := aes.NewCipher(aesKey)
	if err != nil {
		return "", err
	}

	paddedText := pad([]byte(plainText), aes.BlockSize)
	cipherText := make([]byte, aes.BlockSize+len(paddedText))
	iv := cipherText[:aes.BlockSize]
	if _, err := io.ReadFull(rand.Reader, iv); err != nil {
		return "", err
	}

	mode := cipher.NewCBCEncrypter(block, iv)
	mode.CryptBlocks(cipherText[aes.BlockSize:], paddedText)

	return base64.StdEncoding.EncodeToString(cipherText), nil
}

func decryptData(encryptedCode string) (string, string, error) {
	cipherText, err := base64.StdEncoding.DecodeString(encryptedCode)
	if err != nil {
		return "", "", err
	}

	block, err := aes.NewCipher(aesKey)
	if err != nil {
		return "", "", err
	}

	if len(cipherText) < aes.BlockSize {
		return "", "", errors.New("cipherText too short")
	}

	iv := cipherText[:aes.BlockSize]
	cipherText = cipherText[aes.BlockSize:]
	mode := cipher.NewCBCDecrypter(block, iv)

	paddedText := make([]byte, len(cipherText))
	mode.CryptBlocks(paddedText, cipherText)

	plainText, err := unpad(paddedText, aes.BlockSize)
	if err != nil {
		return "", "", err
	}

	parts := strings.Split(string(plainText), "|")
	if len(parts) != 3 {
		return "", "", errors.New("invalid data format")
	}

	groupID := parts[0]
	subgroupID := parts[1]
	expiration, err := strconv.ParseInt(parts[2], 10, 64)
	if err != nil || time.Now().Unix() > expiration {
		return "", "", errors.New("code expired or invalid")
	}

	return groupID, subgroupID, nil
}

func pad(data []byte, blockSize int) []byte {
	padding := blockSize - len(data)%blockSize
	padText := make([]byte, padding)
	for i := range padText {
		padText[i] = byte(padding)
	}
	return append(data, padText...)
}

func unpad(data []byte, blockSize int) ([]byte, error) {
	length := len(data)
	padding := int(data[length-1])
	if padding > blockSize || padding == 0 {
		return nil, errors.New("invalid padding")
	}
	return data[:length-padding], nil
}

// Handlers
func encryptHandler(c echo.Context) error {
	groupID := c.FormValue("groupId")
	subgroupID := c.FormValue("subgroupId")
	if groupID == "" || subgroupID == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Missing parameters"})
	}

	encrypted, err := encryptData(groupID, subgroupID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Encryption failed: " + err.Error()})
	}

	return c.String(http.StatusOK, encrypted)
}

func getKeycloakConfigHandler(c echo.Context) error {
	clientID := getEnv("KEYCLOAK_CLIENT_ID", "")
	clientSecret := getEnv("KEYCLOAK_CLIENT_SECRET", "")

	if clientID == "" || clientSecret == "" {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Missing Keycloak configuration"})
	}

	response := map[string]string{
		"KCID":     clientID,
		"KCSecret": clientSecret,
	}

	return c.JSON(http.StatusOK, response)
}

func setPersistentCookies(c echo.Context) error {
	cookieName := c.QueryParam("name")
	cookieValue := c.QueryParam("value")

	// Check if name or value is empty
	if cookieName == "" || cookieValue == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Missing cookie name or value"})
	}

	// Create the cookie
	cookie := &http.Cookie{
		Name:     cookieName,
		Value:    cookieValue,
		Path:     "/",
		Domain:   "localhost",
		MaxAge:   34560000, // 400 days
		Secure:   false,    // Set to false for local development over HTTP
		HttpOnly: true,
		SameSite: http.SameSiteLaxMode, // Consider changing to Lax for local development
	}

	// Set the cookie
	c.SetCookie(cookie)

	// Return a successful status code
	return c.NoContent(http.StatusOK)
}

func getCookies(c echo.Context) error {
	cookieName := c.QueryParam("name")
	if cookieName == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Missing cookie name"})
	}

	cookie, err := c.Cookie(cookieName)
	if err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "Cookie not found"})
	}

	return c.String(http.StatusOK, cookie.Value)
}

func deleteCookies(c echo.Context) error {
	cookieName := c.QueryParam("name")
	if cookieName == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Missing cookie name"})
	}

	cookie := &http.Cookie{
		Name:   cookieName,
		Value:  "",
		Path:   "/",
		MaxAge: -1,
	}
	c.SetCookie(cookie)
	return c.NoContent(http.StatusOK)
}

func main() {
	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins:     []string{"http://localhost:3001"}, // Adjust this to your frontend's origin
		AllowMethods:     []string{echo.GET, echo.POST, echo.PUT, echo.DELETE, echo.OPTIONS},
		AllowHeaders:     []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAuthorization},
		ExposeHeaders:    []string{"Authorization"},
		AllowCredentials: true,
	}))

	// Routes
	e.POST("/encrypt", encryptHandler)
	e.GET("/keycloak-config", getKeycloakConfigHandler)
	e.POST("/setCookie", setPersistentCookies)
	e.GET("/getCookie", getCookies)
	e.DELETE("/deleteCookie", deleteCookies)
	e.POST("/user", handler.SaveUser)
	fmt.Println("Server running at http://localhost:3002")
	// Start server
	e.Logger.Fatal(e.Start(":3002"))
}
