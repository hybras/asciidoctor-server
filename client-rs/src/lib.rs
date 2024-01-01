pub mod grpc {
    tonic::include_proto!("asciidoctor");
}

mod cli;

use cli::Args;