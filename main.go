package main

import (
	"database/sql"
	"log"

	"github.com/laserbeans741/simplebank-udemy/api"
	db "github.com/laserbeans741/simplebank-udemy/db/sqlc"
	"github.com/laserbeans741/simplebank-udemy/util"
	_ "github.com/lib/pq"
)

func main() {
	config, err := util.LoadConfig(".")
	if err != nil {
		log.Fatal("cannot load config:", err)
	}

	conn, err := sql.Open(config.DBDriver, config.DBSource)

	if err != nil {
		log.Fatal("cannot connect to db:", err)
	}

	store := db.NewStore(conn)
	server := api.NewServer(store)

	err = server.Start(config.ServerAddress)
	if err != nil {
		log.Fatal("cannot stat server", err)
	}

}
