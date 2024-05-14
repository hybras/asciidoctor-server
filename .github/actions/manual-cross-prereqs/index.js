require("@actions/core");
require("@actions/exec");

async function run() {
  try {
    const target = core.getInput('target');
    if (!target.includes('-unknown-linux-')) {
      throw new Error(`Cross compilation is only supported for Linux targets and hosts.`);
    }
    const ARCH = target.split('-')[0];
    const OTHER = target.split('-')[3];
    let PACKAGE_ARCH = "NOPE";

    switch (ARCH) {
      case 'arm':
        switch (OTHER) {
          case 'gnueabihf':
          case 'musleabihf':
            PACKAGE_ARCH = "armhf";
            break;
          case 'gnueabi':
          case 'musleabi':
            PACKAGE_ARCH = "armel";
            break;
          default:
            throw new Error(`Unsupported architecture: ${ARCH}-${OTHER}`);
        }
        break;
      case 'aarch64':
        PACKAGE_ARCH = "arm64";
        break;
      case 'x86_64':
        PACKAGE_ARCH = "amd64";
        break;
      case 'i686':
        PACKAGE_ARCH = "i386";
        break;
      default:
        throw new Error(`Unsupported architecture: ${ARCH}`);
    }

    core.exportVariable('DEBIAN_FRONTEND', 'noninteractive');
    await exec.exec('sudo', ['apt-get', 'install', `crossbuild-essential-${PACKAGE_ARCH}`]);
  } catch (error) {
    core.setFailed(error.message);
  }
}