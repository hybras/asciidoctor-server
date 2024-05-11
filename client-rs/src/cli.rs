use url::Url;

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

    /// input (only accepts stdin). This mandatory argument should always be set to stdin, or "-". However, since argh doesn't support passing in such an argument, feel free to write whatever "filename" instead, I use "yeet". This argument will be ignored.
    #[argh(positional, greedy)]
    pub input: Vec<String>,

    /// max timeout time for exponential backoff
    #[argh(option, default = "2")]
    pub max_timeout: u64
}

fn default_server_address() -> Url {
    Url::parse(
        format!(
            "unix:{}",
            std::env::current_dir()
                .unwrap()
                .join(".asciidoctor-server.sock")
                .display()
        )
        .as_str(),
    )
    .unwrap()
}
