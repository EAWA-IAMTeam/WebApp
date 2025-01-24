package middleware

import (
	"net/http"
	"strings"

	"github.com/labstack/echo/v4"
)

// AuthMddileware verifies the JWT token and sets the user in a context
func AuthMiddleware(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		authHeader := c.Request().Header.Get("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer") {
			return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Missing or invalid token"})
		}
	}
}
