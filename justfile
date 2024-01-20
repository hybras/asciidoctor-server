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
    just run-server &
    sleep 1
    s=$(echo '*hello*' | just run-client)
    diff -w <(echo $s) - <<EOF
    <div class="paragraph"><p><strong>hello</strong></p></div>
    EOF
    kill "%1"
