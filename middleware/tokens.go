package middleware

import (
	"auth_ecommerce/models"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

var jwtKey = []byte("your-secret-key")

// GenerateToken generates a JWT token
func GenerateToken(username, role string) (string, error) {
	expirationTime := time.Now().Add(24 * time.Hour)
	claims := &models.Claims{
		Username: username,
		Role:     role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtKey)
}
