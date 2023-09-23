use anyhow::anyhow;

fn map_magnus_err(_err: magnus::Error) -> anyhow::Error {
    return anyhow!("ruby eval error");
}

#[cfg(test)]
mod tests {

    use rusty_fork::fork_test;

    #[fork_test]
    #[test]
    fn test_magnus() -> magnus::error::Result<()> {
        let ruby = unsafe { magnus::embed::init() };
        let ruby = &*ruby;
        let res = ruby.eval::<i64>("1 + 1")?;
        assert_eq!(res, 2);
        Ok(())
    }

    #[fork_test]
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
    }
}
