use futures::{Sink, Stream};
use std::net::SocketAddr;
use std::task::Poll;
use std::{marker::PhantomData, pin::Pin};
use zmq::{Message, PollEvents};

struct ZmqSocket<StreamItem, SinkItem>(
    zmq::Socket,
    SocketAddr,
    PhantomData<StreamItem>,
    PhantomData<SinkItem>,
);

impl<StreamItem, SinkItem> ZmqSocket<StreamItem, SinkItem> {
    fn new(socket: zmq::Socket, address: SocketAddr) -> Self {
        Self(socket, address, PhantomData, PhantomData)
    }
}

impl<StreamItem, SinkItem> Sink<SinkItem> for ZmqSocket<StreamItem, SinkItem>
where
    SinkItem: Into<zmq::Message>,
{
    type Error = zmq::Error;

    fn poll_ready(
        self: Pin<&mut Self>,
        cx: &mut std::task::Context<'_>,
    ) -> Poll<Result<(), Self::Error>> {
        let ev = self.0.get_events();
        match ev {
            Err(err) => Poll::Ready(Err(err)),
            Ok(ev) => {
                if ev.contains(PollEvents::POLLOUT) {
                    Poll::Ready(Ok(()))
                } else {
                    Poll::Pending
                }
            }
        }
    }

    fn start_send(self: std::pin::Pin<&mut Self>, item: SinkItem) -> Result<(), Self::Error> {
        self.0.send(item, 0)
    }

    fn poll_flush(
        self: std::pin::Pin<&mut Self>,
        cx: &mut std::task::Context<'_>,
    ) -> std::task::Poll<Result<(), Self::Error>> {
        // self.0.get_backlog();
        unimplemented!()
    }

    fn poll_close(
        self: std::pin::Pin<&mut Self>,
        cx: &mut std::task::Context<'_>,
    ) -> std::task::Poll<Result<(), Self::Error>> {
        std::task::Poll::Ready(Ok(()))
    }
}

impl<StreamItem, SinkItem> Stream for ZmqSocket<StreamItem, SinkItem>
where
    Message: Into<StreamItem>,
{
    type Item = Result<StreamItem, zmq::Error>;

    fn poll_next(
        self: Pin<&mut Self>,
        cx: &mut std::task::Context<'_>,
    ) -> Poll<Option<Self::Item>> {
        let ev = if let Ok(ev) = self.0.get_events() {
            ev
        } else {
            return Poll::Ready(None);
        };
        if !ev.contains(PollEvents::POLLIN) {
            return Poll::Pending;
        }
        let msg = self.0.recv_msg(0).map(|msg| msg.into());

        Poll::Ready(Some(msg))
    }
}

#[cfg(test)]
mod tests {
    use zmq::Context;

    use super::*;

    #[test]
    fn it_works() -> zmq::Result<()> {
        use tarpc::Transport;
        let ctx: Context = zmq::Context::new();
        let skt = ctx.socket(zmq::SocketType::REQ)?;
        skt.bind("127.0.0.1:8080")?;
        let skt: ZmqSocket<String, String> = ZmqSocket::new(skt, "127.0.0.1:8080".parse().unwrap());
        Ok(())
    }
}
