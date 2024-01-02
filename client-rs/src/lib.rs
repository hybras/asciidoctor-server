pub mod grpc {
    tonic::include_proto!("asciidoctor");
}

mod cli;

pub use cli::Args;
