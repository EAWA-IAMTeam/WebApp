package models

import "github.com/golang-jwt/jwt/v5"

//Claims represents the JWT claims
type Claims struct {
	Username string `json:"username"`
	Role     string `json:"role"`
	jwt.RegisteredClaims
}
