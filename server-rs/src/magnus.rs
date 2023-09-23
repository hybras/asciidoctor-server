use anyhow::anyhow;

fn map_magnus_err(_err: magnus::Error) -> anyhow::Error {
    return anyhow!("ruby eval error");
}

#[cfg(test)]
mod tests {

    use rusty_fork::rusty_fork_test;

    rusty_fork_test! {
    #[test]
    fn test_magnus() {
        let ruby = unsafe { magnus::embed::init() };
        let ruby = &*ruby;
        let res = ruby.eval::<i64>("1 + 1").expect("eval pure, closed expr failed");
        assert_eq!(res, 2);
    }}

    rusty_fork_test! {
    #[test]
    fn test_asciidoctor_require() {
        let cleanup = unsafe { magnus::embed::init() };
        let ruby = &*cleanup;
        let req_asciidoctor = ruby.require("asciidoctor").expect("req asciidoctor");
        assert!(req_asciidoctor);
        // let loc = ruby.eval::<String>("RbConfig.ruby")?;
        // dbg!(loc);
        // let gem_home = std::env::var("GEM_HOME").unwrap();
        // dbg!(gem_home);
    }}
}
