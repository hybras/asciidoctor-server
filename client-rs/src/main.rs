fn main() -> std::io::Result<()> {
    let args: asciidoctor_batch_client::Args = argh::from_env();
    println!("{:?}", args);
    Ok(())
}
