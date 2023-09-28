// Package main implements a client for Greeter service.
package main

import (
	"context"
	// "flag"
	"log"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	pb "io.github.hybras/asciidoctor-server/proto"
)

// var (
//
//	addr = flag.String("addr", "unix://.asciidoctor-server", "the address to connect to")
//	backend = flag.String("backend", "html5", "backend")
//
// )
// const ADDR = "unix:///Users/hybras/Documents/asciidoctor-server/socket.sock";
const ADDR = "localhost:50051"

func main() {
	// flag.Parse()
	// Set up a connection to the server.
	conn, err := grpc.Dial(ADDR, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewAsciidoctorConverterClient(conn)

	// Contact the server and print out its response.
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	r, err := c.Convert(ctx, &pb.AsciidoctorConvertRequest{
		// Extensions: []string{},
		Backend: "html5",
		// Attributes: []string{},
		Input: "\n" +
			"= Asciidoctor Hello\n" +
			"\n" +
			"Paragraph\n",
	})
	if err != nil {
		log.Fatalf("could not convert: %v", err)
	}
	log.Printf("Output:\n%s", r.GetOutput())
}
