<p align="center">
<h1 align="center"><b>Simplebank Project</b></h1>
<p align="center">
An application to explore Go API development, database migrations, DevOps, and gRPC. <br/>
Based on the Udemy course by <a href="https://github.com/techschool/simplebank">Tech School</a>
</p>
</p>
<hr/>

## Project Overview

This project implements a fairly simple API for modeling bank transactions. Data
is persisted in PostgresQL, and two APIs are implemented: one with [Gin](https://github.com/gin-gonic/gin) and
one with [gRPC](https://grpc.io/).

A user can create a new user profile, and then use that profile to log in.
Passwords are hashed using `bcrypt`, and sessions are persisted in the database
allowing the administrator to mark a session as invalid in case of a security
incident. Log-in tokens are refreshed on a pre-set time increment until the
session token expires, then the user must log in again.

When logged in, the user can create any number of accounts with different
assigned currencies, so long as each user only has one account for each
currency. The user can initiate a transfer to accounts owned by other users.

## Database

Database interractions are handled with a series of tools: [golang-migrate](https://github.com/golang-migrate/migrate)
handles database schema management, [sqlc](https://sqlc.dev/) generates Go code for interracting
with the database, and [gomock](https://github.com/golang/mock) mocks database transactions for testing.

### Database Migrations

Incremental schema files are stored in `db/migration`. This provides a clean way
to manage changes to the database schema, and can facilitate upgrading the
schema of a database which is already populated with data. It also ensures that
the development, testing, and production databases are all in sync to prevent
configuration drift.

### Database interactions

Database queries are defined in `db/query`. These are the actual SQL operations
which will be executed on the database server. These are used along with
[sqlc](https://sqlc.dev/) and the configuration file `sqlc.yaml` to generate type-aware
convenience functions which will be used for database interactions.

This repository uses [gomock](https://github.com/golang/mock) to model database transactions for testing.

## API

The API is implemented two ways: once as a plain REST API with [Gin](https://github.com/gin-gonic/gin), and once
as a gRPC API with REST reverse proxy using [gRPC](https://grpc.io/).

The Gin implementation is in the `api` folder, and files related to the gRPC
server are located in the `proto` and `gapi` folders.

Before the server is compiled, the type of API desired to serve is configurable
in `main.go`.

## Security

This API uses token-based authentication for all API calls (except creating a
new user). After log-in, the user is given a token which will be attached to API
requests requiring authentication. The Go server checks authentication before
executing database operations.

The token-based authentication is implemented two ways: [jwt](https://jwt.io/) and [paseto](https://paseto.io/).
Token creation is abstracted behind a `TokenMaker` interface to simplify
changing token schemes and the future implementation of new token generation
methods.

HTTPS is handled at the point of deployment via reverse proxy for both Gin and
gRPC endpoints.

## Deployment

The repository has two actions configured in `.github/actions`. One for running
tests which is triggered by any merge request to `main`, and one for deployment
to k8s on AWS upon the completion of a merge request to `main`. These actions
are currently disabled because I didn't feel the need to continue paying the
associated AWS costs. On the AWS side, an IAM role was created specifically for
deployment from GitHub actions with only the permissions required to push to the
private container registry, and deploy to the EKS kubernetes cluster.
Authentication details are handled via GitHub secrets.

### Docker

The `Dockerfile` describes a two-stage build process: the first builds the Go
project, and then necessary files are copied into the second stage for running
in production.

The `docker-compose` configuration spins up a Postgres server and API server in
the local environment.

### Kubernetes

Kubernetes configuration is in the `eks` folder. These configurations handle
ingress, SSL, the service, and deployment. The nginx ingress configuration uses
[cert-manager.io](https://cert-manager.io/) to automatically set up SSL with
LetsEncrypt. The production environment uses Amazon RDS to serve the Postgres
sever. Connection credentials are handled by Kubernetes secrets.

## Workflow

The local development environment is fairly simple: a local postgres sever is
run in docker, and code is run either manually, via an IDE, or using the
automated test.

When the developer is satisfied with the completion of a feature, a merger
request will be created to merge the feature branch into `main`. At this point,
automated tests are run via GitHub actions. If quality tests pass, the merge
request is eligible for approval pending code review.

Upon a completed merge to `main`, the deployment action runs which will build a
new docker container and deploy to k8s on AWS.
