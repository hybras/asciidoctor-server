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
    export ASCIIDOCTOR_SERVER_ADDRESS="${ASCIIDOCTOR_SERVER_ADDRESS:-unix:$PWD/.asciidoctor-server.sock}"
    just server/run 2> /dev/null &
    actual=$(echo '*hello*' | just client-rs/run | tr -d '\n')
    if [[ -n "${CI:-}" ]]; then
        echo "Running test in CI environment. Don't kill test server process"
    else
        kill -9 $(pgrep asciidoctor-server)
    fi
    expected="<div class=\"paragraph\"><p><strong>hello</strong></p></div>"
    diff -w <(echo "$actual") <(echo "$expected")
    echo "Test passed"
