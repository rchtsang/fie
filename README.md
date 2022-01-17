# Reproducing FiE on Firmware

This repository was created for the purposes of reproducing the results from the 2013 USENIX paper [*FiE on Firmware: Finding Vulnerabilities in Embedded Systems Using Symbolic Execution* by Drew Davidson, Benjamin Moench, Somesh Jha, and Thomas Ristenpart](https://www.usenix.org/conference/usenixsecurity13/technical-sessions/paper/davidson). 

This mainly provides a Vagrantfile with associated provisioning scripts that sets up the development environment for building the FiE project, the original source for which can be found on its [official website](http://pages.cs.wisc.edu/~davidson/fie/). As of 1/2022, the source code is still available from there. 

Note that this repository does not provide the FiE source code as the archive file size is too large. However, when the vagrant box is provisioned, it will download and extract it to the project directory. (see `provision.sh`)

To download manually: 
```sh
wget "http://pages.cs.wisc.edu/~davidson/fie/fie.tgz"
```
To extract manually:
```sh
tar -zxvf fie.tgz
```

## About

FiE is a symbolic execution engine based on KLEE, specifically targeted for finding vulnerabilities in the firmware of MSP430 Microcontrollers.

## Building FiE

_(From the official build instructions)_

Configure FiE using the standard configure script:

```sh
cd fie
./configure
```

In addition to recursively invoking child configure scripts, this script will also create a file `env.src` at the root of your FiE source tree. This file can be sourced to set up environment variables needed during when you install and invoke FiE. The following environment variables are set by `env.src`:

1. `C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu`
2. `CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu`
3. `PATH=LLVM_BIN:FIE_BIN:$PATH`

Where `LLVM_BIN` is the directory is a directory where the `llvm-2.9` and `clang` binaries reside and `FIE_BIN` is the location where the fie binary resides (this will be determined by the configure script). Items one and two are dependencies inherited from the underlying KLEE implementation, and may be necessary for your architecture.
At this point, everything is ready to go. Run
```sh
make
```
and wait for everything to build. If you are building the complete bundle with `llvm` and `clang` included, this can take some time.

## Vagrant and Additional Dependencies

In order to reproduce the original build environment (64-bit Ubuntu 12.04) we make use of **Vagrant** and **VirtualBox**. This is to reduce the potential for errors due to build environment. The build should take place in the Vagrant VM, in which the necessary build dependencies have been installed per the [documentation](http://pages.cs.wisc.edu/~davidson/fie/directions.html).

```sh
# construct and log into vm
vagrant up
vagrant ssh    # password: vagrant

# build fie
cd fie
./configure
source env.src
make
```

**Note:** There is a typo in the official dependency installation instructions. there is no such thing as the `flexl` package, it should be `flex`. Probably.

**Note:** Although FiE source comes with the `llvm-2.9` source code, it doesn't seem to build `clang`. To fix this I use the `clang+llvm-2.9` provided on the [LLVM releases page](https://releases.llvm.org/download.html#2.9). This fix also requires the `libc6-dev-i386` package, per [this](https://github.com/klee/klee/issues/83) issue on github

### Installing on Deprecated Ubuntu

The original project developed on 64-bit Ubuntu 12.04 (Precise Pangolin). This is a deprecated release of Ubuntu and as such, packages are no longer hosted on the default servers. This means `apt-get` cannot be used as-is. To fix this, we need to change the servers in `/etc/apt/sources.list` from `us.archive` and `security` to [`old-releases`](http://old-releases.ubuntu.com/) per [this question on stack exchange](https://superuser.com/questions/301432). 

This should be handled by the provisioning script.

## Helpful Links

- <a id="fie-website" href="http://pages.cs.wisc.edu/~davidson/fie/">FiE on Firmware (Official Website)</a>
- <a id="fie-getting-started" href="http://pages.cs.wisc.edu/~davidson/fie/directions.html">FiE: Getting Started</a>

## References

1. Drew Davidson, Benjamin Moench, Somesh Jha, and Thomas Ristenpart. 2013. FIE on firmware: finding vulnerabilities in embedded systems using symbolic execution. In Proceedings of the 22nd USENIX conference on Security (SEC'13). USENIX Association, USA, 463–478. [url](https://www.usenix.org/system/files/conference/usenixsecurity13/sec13-paper_davidson.pdf)

