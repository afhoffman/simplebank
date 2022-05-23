package api

import (
	"github.com/gin-gonic/gin"
	db "github.com/laserbeans741/simplebank-udemy/db/sqlc"
)

//  Serves HTTP requests for banking service
type Server struct {
	store  db.Store
	router *gin.Engine
}

// Create a new HTTP server and setup routing
func NewServer(store db.Store) *Server {
	server := &Server{store: store}
	router := gin.Default()

	router.POST("/accounts", server.createAccount)
	router.POST("/accounts/update", server.updateAccount)
	router.GET("/accounts/:id", server.getAccount)
	router.GET("/accounts", server.listAccount)
	router.GET("/accounts/delete/:id", server.deleteAccount)

	server.router = router
	return server
}

func (server *Server) Start(address string) error {
	return server.router.Run(address)
}

func errorResponse(err error) gin.H {
	return gin.H{"error": err.Error()}
}
