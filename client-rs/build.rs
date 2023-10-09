use std::io::Result;

fn main() -> Result<()> {
    println!("{}", std::env::var("OUT_DIR").unwrap());
    tonic_build::compile_protos("src/asciidoctor.proto")?;
    Ok(())
}
