require "grpc"
require "optparse"

module Asciidoctor
  module Server
    module Cli
      Options = Struct.new(:thread_pool_size, :address) do
        def self.parse(args)
          Options.new(
            ::GRPC::RpcServer::DEFAULT_POOL_SIZE,
            "unix://#{Pathname.pwd / ".asciidoctor-server.sock"}"
          ).parse(args)
        end
        def parse(args)
          positional_args = OptionParser.new do |parser|
            parser.on("-addr ADDRESS", "--address ADDRESS")
            parser.on("-t THREAD_POOL_SIZE", "--thread_pool_size", Integer, "thread pool size")
            parser.on("-h", "--help", "print help") do
              puts parser
              exit
            end
          end.parse(args, into: self)
          return self
        end
      end
    end
  end
end