# frozen_string_literal: true

require "grpc"
require "optparse"

module Asciidoctor
  module Server
    module Cli
      Options = Struct.new(:thread_pool_size, :address) do
        def self.parse(args)
          Options.new(
            ::GRPC::RpcServer::DEFAULT_POOL_SIZE,
            ENV["ASCIIDOCTOR_SERVER_ADDRESS"] || "unix://#{Pathname.pwd / ".asciidoctor-server.sock"}"
          ).parse(args)
        end

        def parse(args)
          OptionParser.new do |parser|
            parser.banner = "Usage: asciidoctor-server [options]"
            parser.on("-addr ADDRESS", "--address ADDRESS",
              "Server address (default: unix socket, can be overridden with ASCIIDOCTOR_SERVER_ADDRESS env var)")
            parser.on("-t THREAD_POOL_SIZE", "--thread_pool_size", Integer, "thread pool size")
            parser.on("-h", "--help", "print help") do
              puts parser
              exit
            end
          end.parse(args, into: self)
          self
        end
      end
    end
  end
end
