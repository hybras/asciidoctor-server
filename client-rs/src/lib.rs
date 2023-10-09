use url::Url;

pub mod grpc {
    tonic::include_proto!("asciidoctor");
}

#[derive(argh::FromArgs, Debug)]
/// All Args
pub struct Args {
    /// extensions
    #[argh(option, short = 'r')]
    pub extensions: Vec<String>,
    /// backend
    #[argh(option, short = 'b', default = "\"html5\".to_string()")]
    pub backend: String,
    /// attributes
    #[argh(option, short = 'a')]
    pub attributes: Vec<String>,

    /// whether the output is meant to be embedded into another document.
    #[argh(switch, short = 's')]
    pub no_header_footer: bool,

    /// server address
    #[argh(option, long = "address", default = "default_server_address()")]
    pub server_address: url::Url,

    // from_str_fn(input_is_stdin)
    /// input (only accept stdin)
    #[argh(positional, greedy)]
    pub input: Vec<String>,
}

fn default_server_address() -> Url {
    Url::parse(
        format!(
            "unix:{}",
            std::env::current_dir()
                .unwrap()
                .join("../.asciidoctor-server.sock")
                .display()
        )
        .as_str(),
    )
    .unwrap()
}
