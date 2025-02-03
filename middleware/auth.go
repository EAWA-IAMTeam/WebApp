package middleware

import (
	"net/http"
	"strings"

	"auth_ecommerce/models"

	"github.com/golang-jwt/jwt/v5"
	"github.com/labstack/echo/v4"
)

// AuthMddileware verifies the JWT token and sets the user in a context
func AuthMiddleware(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		authHeader := c.Request().Header.Get("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer") {
			return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Missing or invalid token"})
		}
		tokenString := strings.TrimPrefix(authHeader, "Bearer ")

		claims := &models.Claims{}
		token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
			return jwtKey, nil
		})

		if err != nil || !token.Valid {
			return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Invalid token"})
		}

		//Add user details to context
		c.Set("user", claims)
		return next(c)
	}
}
