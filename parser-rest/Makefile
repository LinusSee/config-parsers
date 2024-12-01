include .envrc

# Keep this first, because if no target is specified for make, the first one will be run
## help: print help messages for all commands
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]



# ===================================================================================== #
# DEVELOPMENT
# ===================================================================================== #

## run/api: run the cmd/api application
.PHONY: run/api
run/api:
	go run ./cmd/api -db-dsn=${CONFIG_PARSER_DSN} -cors-trusted-origins="localhost:1234 http://localhost:1234 http://localhost:1234/"

## db/migrations/new name=$1: create new database migration files
.PHONY: db/migrations/new
db/migrations/new:
	@echo 'Creating migration files for ${name}'
	migrate create -seq -ext=.sql -dir=./migrations ${name}

## db/migrations/up: apply all up database migrations. Requires confirmation
.PHONY: db/migrations/up
db/migrations/up: confirm
	@echo 'Running up migrations'
	migrate -path ./migrations -database ${CONFIG_PARSER_DSN} up