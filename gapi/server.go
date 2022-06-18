package gapi

import (
	"fmt"

	db "github.com/laserbeans741/simplebank-udemy/db/sqlc"
	"github.com/laserbeans741/simplebank-udemy/pb"
	"github.com/laserbeans741/simplebank-udemy/token"
	"github.com/laserbeans741/simplebank-udemy/util"
)

// Server serves gRPC requests for our banking service
type Server struct {
	pb.UnimplementedSimpleBankServer
	config     util.Config
	store      db.Store
	tokenMaker token.Maker
}

// Create a new gRPC server
func NewServer(config util.Config, store db.Store) (*Server, error) {
	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	if err != nil {
		return nil, fmt.Errorf("cannot create token maker: %w", err)

	}
	server := &Server{
		config:     config,
		store:      store,
		tokenMaker: tokenMaker,
	}

	return server, nil
}
