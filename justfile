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

test:
    #!/bin/bash
    just server/run &
    actual=$(echo '*hello*' | just client-rs/run)
    expected="<div class="paragraph"><p><strong>hello</strong></p></div>"
    diff -w <(echo $s) - <<< "$expected"
    kill "%1"
