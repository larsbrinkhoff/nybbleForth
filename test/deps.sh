install_lbforth() {
    cd lbForth
    export M32=-m32
    sh -e install-deps.sh install_${TRAVIS_OS_NAME:-linux}
    make all TARGET=x86 OS=linux
    sudo make install TARGET=x86 OS=linux
}

sudo apt-get update -yqqm

wget https://github.com/tgingold/ghdl/releases/download/v0.33/ghdl_0.33-1ubuntu1_amd64.deb
sudo dpkg -i ghdl_0.33-1ubuntu1_amd64.deb || echo ignore failure
sudo apt-get install -f

sudo apt-get install -ym iverilog freehdl

(install_lbforth)
