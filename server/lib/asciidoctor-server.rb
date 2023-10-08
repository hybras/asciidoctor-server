# frozen_string_literal: true

require_relative "asciidoctor-server/version"
require_relative "asciidoctor-server/asciidoctor_services_pb"

module Asciidoctor
  module Server
    class AsciidoctorServer < Asciidoctor::Server::AsciidoctorConverter::Service
      def convert(convert_req, _unused_call)
        convert_req.extensions.each { |ext| require(ext) }
        doc = Asciidoctor.convert(
          convert_req.input,
          backend: convert_req.backend,
          attributes: convert_req.attributes.to_a,
          standalone: convert_req.standalone
        )
        ::Asciidoctor::Server::AsciidoctorConvertReply.new(output: doc)
      end
    end
  end
end
