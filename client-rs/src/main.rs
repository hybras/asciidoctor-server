use backon::{ExponentialBuilder, Retryable};
use cfg_if::cfg_if;
use tonic::transport::{Endpoint, Uri};
use tower::service_fn;

use asciidoctor_client::Args;
use std::io::Read;
use std::process::Command;
use std::time::Duration;

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
        max_timeout,
    } = argh::from_env();
    let addy = server_address.clone();
    let backoff = ExponentialBuilder::default()
        .with_min_delay(Duration::from_millis(125))
        .with_max_times(4)
        .with_max_delay(Duration::from_secs(max_timeout))
        .with_jitter();
    let endpoint = Endpoint::try_from("http://[::]:50051")?;
    let connector;
    std::fs::read_to_string("/etc/os-release")
        .map_err(|_| "Failed to read /etc/os-release")?;
    cfg_if!(
        if #[cfg(unix)] {
            connector = move |_: Uri| {
                use tokio::net::UnixStream;
                UnixStream::connect(addy.path().to_owned())
            };
        } else if #[cfg(windows)] {
            connector = async move |_: Uri| {
                use tokio::net::windows::named_pipe as pipe;
                pipe::ClientOptions::new().open(addy.path().to_owned())
            };
        } else {
            compile_error!("Not windows or unix")
        }
    );

    let channel = match server_address.scheme() {
        "unix" => {
            (|| endpoint.connect_with_connector(service_fn(connector.clone())))
                .retry(&backoff)
                .await?
        }
        _ => (|| endpoint.connect()).retry(&backoff).await?,
    };

    let mut input = String::new();
    let mut stdin = std::io::stdin().lock();
    stdin.read_to_string(&mut input)?;
    drop(stdin);
    let input = input;

    let request = AsciidoctorConvertRequest {
        input,
        attributes,
        backend,
        extensions,
        standalone: no_header_footer,
    };

    let convert = || async {
        let mut client = AsciidoctorConverterClient::new(channel.clone());
        client.convert(tonic::Request::new(request.clone())).await
    };

    let output = convert.retry(&backoff).await?.into_inner().output;

    println!("{}", output);

    Ok(())
}
