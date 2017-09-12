install_lbforth() {
    cd lbForth
    export M32=-m32
    sh -e test/install-deps.sh install_${TRAVIS_OS_NAME:-linux}
    make all TARGET=x86 OS=linux
    sudo make install TARGET=x86 OS=linux
}

sudo apt-get update -yqqm
sudo apt-get install -ym iverilog verilator

(install_lbforth)
