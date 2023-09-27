// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.2.0
// - protoc             v3.21.12
// source: asciidoctor.proto

package proto

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

// AsciidoctorConverterClient is the client API for AsciidoctorConverter service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type AsciidoctorConverterClient interface {
	Convert(ctx context.Context, in *AsciidoctorConvertRequest, opts ...grpc.CallOption) (*AsciidoctorConvertReply, error)
}

type asciidoctorConverterClient struct {
	cc grpc.ClientConnInterface
}

func NewAsciidoctorConverterClient(cc grpc.ClientConnInterface) AsciidoctorConverterClient {
	return &asciidoctorConverterClient{cc}
}

func (c *asciidoctorConverterClient) Convert(ctx context.Context, in *AsciidoctorConvertRequest, opts ...grpc.CallOption) (*AsciidoctorConvertReply, error) {
	out := new(AsciidoctorConvertReply)
	err := c.cc.Invoke(ctx, "/asciidoctor.AsciidoctorConverter/Convert", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// AsciidoctorConverterServer is the server API for AsciidoctorConverter service.
// All implementations must embed UnimplementedAsciidoctorConverterServer
// for forward compatibility
type AsciidoctorConverterServer interface {
	Convert(context.Context, *AsciidoctorConvertRequest) (*AsciidoctorConvertReply, error)
	mustEmbedUnimplementedAsciidoctorConverterServer()
}

// UnimplementedAsciidoctorConverterServer must be embedded to have forward compatible implementations.
type UnimplementedAsciidoctorConverterServer struct {
}

func (UnimplementedAsciidoctorConverterServer) Convert(context.Context, *AsciidoctorConvertRequest) (*AsciidoctorConvertReply, error) {
	return nil, status.Errorf(codes.Unimplemented, "method Convert not implemented")
}
func (UnimplementedAsciidoctorConverterServer) mustEmbedUnimplementedAsciidoctorConverterServer() {}

// UnsafeAsciidoctorConverterServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to AsciidoctorConverterServer will
// result in compilation errors.
type UnsafeAsciidoctorConverterServer interface {
	mustEmbedUnimplementedAsciidoctorConverterServer()
}

func RegisterAsciidoctorConverterServer(s grpc.ServiceRegistrar, srv AsciidoctorConverterServer) {
	s.RegisterService(&AsciidoctorConverter_ServiceDesc, srv)
}

func _AsciidoctorConverter_Convert_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(AsciidoctorConvertRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(AsciidoctorConverterServer).Convert(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/asciidoctor.AsciidoctorConverter/Convert",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(AsciidoctorConverterServer).Convert(ctx, req.(*AsciidoctorConvertRequest))
	}
	return interceptor(ctx, in, info, handler)
}

// AsciidoctorConverter_ServiceDesc is the grpc.ServiceDesc for AsciidoctorConverter service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var AsciidoctorConverter_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "asciidoctor.AsciidoctorConverter",
	HandlerType: (*AsciidoctorConverterServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Convert",
			Handler:    _AsciidoctorConverter_Convert_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "asciidoctor.proto",
}
