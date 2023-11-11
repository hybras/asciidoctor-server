use tonic::transport::{Endpoint, Uri};
use tower::service_fn;

use asciidoctor_client::Args;
use std::io::Read;

use asciidoctor_client::grpc::asciidoctor_converter_client::AsciidoctorConverterClient;
use asciidoctor_client::grpc::AsciidoctorConvertRequest;

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

    let channel = match dbg!(server_address.scheme()) {
        "unix" => {
            #[cfg(unix)]
            let connector = move |_: Uri| {
                use tokio::net::UnixStream;
                UnixStream::connect(server_address.path().to_owned())
            };

            #[cfg(windows)]
            let connector = move |_: Uri| {
                use tokio::net::windows::named_pipe as pipe;
                pipe::ClientOptions::new().open(server_address.path())
            };

            // We will ignore this uri because uds do not use it
            // if your connector does use the uri it will be provided
            // as the request to the `MakeConnection`.
            Endpoint::try_from("http://[::]:50051")?
                .connect_with_connector(service_fn(connector))
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
