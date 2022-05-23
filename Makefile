postgres:
	docker run --name postgres12 -p 5432:5432 -e POSTGRES_PASSWORD=secret -d postgres:12-alpine

createdb:
	docker exec -it postgres12 createdb --username=postgres --owner=postgres simple_bank

dropdb:
	docker exec -it postgres12 dropdb --username=postgres simple_bank
	
migrateup:
	migrate -path ./db/migration/ -database "postgresql://postgres:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up

migratedown:
	migrate -path ./db/migration/ -database "postgresql://postgres:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen --build_flags=--mod=mod -destination db/mock/store.go github.com/laserbeans741/simplebank-udemy/db/sqlc Store


.PHONY: postgres createdb dropdb migrateup migratedown sqlc test server mock

