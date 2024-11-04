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
    set -euxo pipefail
    just server/run &
    actual=$(echo '*hello*' | just client-rs/run)
    kill -9 $(pgrep asciidoctor-server)
    expected="<div class="paragraph"><p><strong>hello</strong></p></div>"
    diff -w <(echo "$actual") - <<< "$expected"
