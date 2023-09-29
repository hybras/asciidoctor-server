# frozen_string_literal: true

require_relative "asciidoctor-server/version"
require_relative "asciidoctor_services_pb"
require "asciidoctor"
require "logger"
require "grpc"

module MyLogger
  LOGGER = Logger.new $stderr, level: Logger::INFO
  def logger
    LOGGER
  end
end

# Define a gRPC module-level logger method before grpc/logconfig.rb loads.
module GRPC
  extend MyLogger
end

module Asciidoctor
  module Server
    class AsciidoctorServer < Asciidoctor::Server::AsciidoctorConverter::Service
      def convert(convert_req, _unused_call)
        convert_req.extensions.each { |ext| require(ext) }
        doc = Asciidoctor.convert(
          convert_req.input,
          backend: convert_req.backend,
          attributes: convert_req.attributes.to_a,
          )
        ::Asciidoctor::Server::AsciidoctorConvertReply.new(output: doc)
      end
    end
  end
end

def main
  addr = 'unix:///Users/hybras/Documents/asciidoctor-server/socket.sock'
  # addr = "localhost:50051"
  s = GRPC::RpcServer.new
  s.add_http2_port(addr, :this_port_is_insecure)
  s.handle(Asciidoctor::Server::AsciidoctorServer)
  # Runs the server with SIGHUP, SIGINT and SIGTERM signal handlers to
  #   gracefully shutdown.
  # User could also choose to run server via call to run_till_terminated
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGTERM'])
end

main
