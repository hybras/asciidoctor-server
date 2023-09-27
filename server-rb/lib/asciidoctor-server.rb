# frozen_string_literal: true

require_relative "asciidoctor-server/version"
require_relative "asciidoctor_services_pb"
require "asciidoctor"

module Asciidoctor
  module Server
    class AsciidoctorServer < Asciidoctor::Server::AsciidoctorConverter::Service
      def convert(convert_req, _unused_call)
        convert_req.each do |extension|
          require extension
        end
        doc = Asciidoctor.convert(
          convert_req.input,
          backend: convert_req.backend,
          attributes: convert_req.attributes,)
        ::Asciidoctor::Server::Reply.new(output: doc)
      end
    end
  end
end

def main
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(Asciidoctor::Server::AsciidoctorServer)
  # Runs the server with SIGHUP, SIGINT and SIGTERM signal handlers to
  #   gracefully shutdown.
  # User could also choose to run server via call to run_till_terminated
  s.run_till_terminated_or_interrupted([1, 'int', 'SIGTERM'])
end

main
