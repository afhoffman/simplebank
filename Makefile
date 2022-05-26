DB_URL=postgresql://postgres:secret@localhost:5432/simple_bank?sslmode=disable
postgres:
	docker run --name postgres12 --network bank-network -p 5432:5432 -e POSTGRES_PASSWORD=secret -d postgres:12-alpine

createdb:
	docker exec -it postgres12 createdb --username=postgres --owner=postgres simple_bank

dropdb:
	docker exec -it postgres12 dropdb --username=postgres simple_bank
	
migrateup:
	migrate -path ./db/migration/ -database "$(DB_URL)" -verbose up

migrateupone:
	migrate -path ./db/migration/ -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path ./db/migration/ -database "$(DB_URL)" -verbose down

migratedownone:
	migrate -path ./db/migration/ -database "$(DB_URL)" -verbose down 1

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen -package mockdb --build_flags=--mod=mod -destination db/mock/store.go github.com/laserbeans741/simplebank-udemy/db/sqlc Store

dbdocs:
	dbdocs build ./doc/db.dbml

db_schema:
	dbml2sql.ps1 --postgres -o ./doc/schema.sql ./doc/db.dbml

proto:
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
    --go-grpc_out=pb --go-grpc_opt=paths=source_relative \
    proto/*.proto


.PHONY: postgres createdb dropdb migrateup migratedown sqlc test server mock migrateupone migratedownone dbdocs db_schema proto

