// #![cfg_attr(not(unix), allow(unused_imports))]

#[cfg(unix)]
use tokio::net::UnixStream;
use tonic::transport::{Endpoint, Uri};
use tower::service_fn;

use asciidoctor_client::Args;
use std::io::Read;

use asciidoctor_client::grpc::asciidoctor_converter_client::AsciidoctorConverterClient;
use asciidoctor_client::grpc::AsciidoctorConvertRequest;

#[cfg(unix)]
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let Args {
        extensions,
        backend,
        attributes,
        no_header_footer,
        server_address,
        input: _,
    } = argh::from_env();
    // We will ignore this uri because uds do not use it
    // if your connector does use the uri it will be provided
    // as the request to the `MakeConnection`.

    let channel = match dbg!(server_address.scheme()) {
        "unix" => {
            Endpoint::try_from("http://[::]:50051")?
                .connect_with_connector(service_fn(move |_: Uri| {
                    UnixStream::connect(server_address.path().to_owned())
                }))
                .await?
        }
        _ => {
            Endpoint::try_from(server_address.to_string())?
                .connect()
                .await?
        }
    };
    let mut client = AsciidoctorConverterClient::new(channel);
    let mut input = String::new();
    let mut stdin = std::io::stdin().lock();
    stdin.read_to_string(&mut input)?;
    drop(stdin);

    let request = tonic::Request::new(AsciidoctorConvertRequest {
        input,
        attributes,
        backend,
        extensions,
        standalone: no_header_footer,
    });

    let output = client.convert(request).await?.into_inner().output;

    println!("{}", output);

    Ok(())
}

#[cfg(not(unix))]
fn main() {
    panic!("The `uds` example only works on unix systems!");
}
