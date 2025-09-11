use backon::{ExponentialBuilder, Retryable};
use cfg_if::cfg_if;
use tonic::transport::{Endpoint, Uri};
use tower::service_fn;

use asciidoctor_client::Args;
use std::io::Read;
use std::time::Duration;

use asciidoctor_client::grpc::asciidoctor_converter_client::AsciidoctorConverterClient;
use asciidoctor_client::grpc::AsciidoctorConvertRequest;

const UNUSED_HOST: &str = "http://[::]:50051";

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
    let standalone = !no_header_footer;
    let addy = server_address.clone();
    let backoff = ExponentialBuilder::default()
        .with_min_delay(Duration::from_millis(125))
        .with_max_times(4)
        .with_max_delay(Duration::from_secs(max_timeout))
        .with_jitter();

    let channel = create_channel(addy, backoff.clone()).await?;

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
        standalone,
    };

    let convert = || async {
        let mut client = AsciidoctorConverterClient::new(channel.clone());
        client.convert(tonic::Request::new(request.clone())).await
    };

    let output = convert.retry(&backoff).await?.into_inner().output;

    println!("{}", output);

    Ok(())
}

async fn create_channel(
    server_address: url::Url,
    backoff: ExponentialBuilder,
) -> Result<tonic::transport::Channel, Box<dyn std::error::Error>> {
    let endpoint = Endpoint::try_from(UNUSED_HOST)?;

    match server_address.scheme() {
        "unix" => {
            let addy = server_address.clone();
            cfg_if!(
                if #[cfg(unix)] {
                    let connector = move |_: Uri| {
                        use tokio::net::UnixStream;
                        UnixStream::connect(addy.path().to_owned())
                    };
                } else if #[cfg(windows)] {
                    let connector = async move |_: Uri| {
                        use tokio::net::windows::named_pipe as pipe;
                        pipe::ClientOptions::new().open(addy.path().to_owned())
                    };
                } else {
                    compile_error!("Not windows or unix")
                }
            );
            (|| endpoint.connect_with_connector(service_fn(connector.clone())))
                .retry(&backoff)
                .await
        }
        _ => (|| endpoint.connect()).retry(&backoff).await,
    }
    .map_err(|e| e.into())
}
