use futures::StreamExt;
use hubcaps::{Credentials, Github};
use std::env;
use std::error::Error;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    pretty_env_logger::init();
    let token = env::var("GITHUB_TOKEN")?;
    let github = Github::new(
        concat!(env!("CARGO_PKG_NAME"), "/", env!("CARGO_PKG_VERSION")),
        Credentials::Token(token),
    )?;
    let mut files = github
        .repo("rust-lang", "rust")
        .pulls()
        .get(49536)
        .iter_files();
    while let Some(diff) = files.next().await {
        println!("{:#?}", diff?);
    }
    Ok(())
}
