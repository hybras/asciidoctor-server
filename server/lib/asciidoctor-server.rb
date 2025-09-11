# frozen_string_literal: true

require_relative "asciidoctor-server/version"
require_relative "asciidoctor-server/asciidoctor_services_pb"

module Asciidoctor
  module Server
    # Function that wraps the asciidoctor library and returns a gRPC response
    class AsciidoctorServer < Asciidoctor::Server::AsciidoctorConverter::Service
      def convert(convert_req, _unused_call) # rubocop:disable Metrics/MethodLength
        convert_req.extensions.each do |ext|
          require(ext)
        rescue LoadError => e
          return ::Asciidoctor::Server::AsciidoctorConvertReply.new(
            error: "Failed to load extension: #{ext} - #{e.message}"
          )
        end

        doc = Asciidoctor.convert(
          convert_req.input,
          backend: convert_req.backend,
          attributes: convert_req.attributes.to_a,
          standalone: convert_req.standalone
        )
        ::Asciidoctor::Server::AsciidoctorConvertReply.new(output: doc)
      rescue StandardError => e
        ::Asciidoctor::Server::AsciidoctorConvertReply.new(
          error: "Conversion failed: #{e.message}"
        )
      end
    end
  end
end
