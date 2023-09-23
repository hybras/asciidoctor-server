pub mod asciidoctor {
    include!(concat!(env!("OUT_DIR"), "/asciidoctor.rs"));
}

#[derive(argh::FromArgs, Debug)]
/// All Args
pub struct Args {
    /// extensions
    #[argh(option, short = 'r')]
    extensions: Vec<String>,
    /// backend
    #[argh(option, short = 'b', default = "\"html5\".to_string()")]
    backend: String,
    /// attributes
    #[argh(option, short = 'a')]
    attributes: Vec<String>,

    // from_str_fn(input_is_stdin)
    /// input (only accept stdin)
    #[argh(positional, greedy)]
    input: String,
}

fn input_is_stdin(input: &str) -> Result<String, String> {
    match input {
        "-" => Ok(input.to_string()),
        _ => Err("Only stdin supported".to_string()),
    }
}
