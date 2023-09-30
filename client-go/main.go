// Package main implements a client for Greeter service.
package main

import (
	"context"
	"fmt"
	"io"
	"os"

	"github.com/hellflame/argparse"

	// "flag"
	"log"
	"time"

	pb "github.com/hybras/asciidoctor-server/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// const ADDR = "unix:///Users/hybras/Documents/asciidoctor-server/socket.sock";
const ADDR = "localhost:50051"

func main() {
	parser := argparse.NewParser("", "", nil)
	backend := parser.String("b", "backend", &argparse.Option{
		Default: "html5",
	})
	addr := parser.String("addr", "address", &argparse.Option{
		Required: true,
	})
	attributes := parser.Strings("a", "attribute", nil)
	extensions := parser.Strings("r", "require", nil)
	no_header_footer := parser.Flag("", "no-header-footer", nil)
	inputs := parser.Strings("", "files", &argparse.Option{
		Positional: true,
		Required:   true,
		// Validate: func(arg string) error {
		// 	if arg != "-" {
		// 		return errors.New("Only accept stdin, sorry")
		// 	} else {
		// 		return nil
		// 	}
		// },
	})

	if err := parser.Parse(nil); err != nil || len(*inputs) != 1 {
		log.Fatalf("bad args: %v\n%v", err, os.Args)
	}

	stdin, err := io.ReadAll(os.Stdin)

	if err != nil {
		log.Fatalf("Could not read stdin: %v", err)
	}
	input := string(stdin)

	// Set up a connection to the server.
	conn, err := grpc.Dial(*addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewAsciidoctorConverterClient(conn)

	// Contact the server and print out its response.
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	r, err := c.Convert(ctx, &pb.AsciidoctorConvertRequest{
		Extensions: *extensions,
		Backend:    *backend,
		Attributes: *attributes,
		Input:      input,
		Standalone: !*no_header_footer,
	})
	if err != nil {
		log.Fatalf("could not convert: %v", err)
	}
	fmt.Print(r.GetOutput())
}
