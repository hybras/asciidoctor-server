default:
    @just --list

run-client:
    @just client-rs/run

run-server:
    @just server/run

client-go:
    go run client-go/main.go

protoc-go:
    protoc \
        --go_out=./client-go \
        --go_opt=paths=source_relative \
        --go-grpc_out=./client-go \
        --go-grpc_opt=paths=source_relative \
        proto/asciidoctor.proto
