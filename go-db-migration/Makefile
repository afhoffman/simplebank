createdb:
	docker exec -it postgres12 createdb --username=postgres --owner=postgres simple_bank
dropdb:
	docker exec -it postgres12 dropdb --username=postgres simple_bank
postgres:
	docker run --name postgres12 -p 5432:5432 -e POSTGRES_PASSWORD=secret -d postgres:12-alpine
migrateup:
	migrate -path ./db/migration/ -database "postgresql://postgres:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up
migratedown:
	migrate -path ./db/migration/ -database "postgresql://postgres:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down

.PHONY: createdb

