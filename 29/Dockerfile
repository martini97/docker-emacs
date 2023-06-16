FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CC=/usr/bin/gcc-10
ENV CXX=/usr/bin/gcc-10
ENV LD_LIBRARY_PATH=/usr/local/lib/

RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list
RUN apt update
RUN apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    libgccjit-10-dev \
    gcc-10 \
    libtree-sitter-dev \
    libjansson-dev \
    libjansson4

RUN apt build-dep -y emacs

RUN git clone --depth 1 --single-branch --branch emacs-29 git://git.savannah.gnu.org/emacs.git /emacs

WORKDIR /emacs

RUN ./autogen.sh
RUN ./configure \
    --with-native-compilation=aot \
    --with-tree-sitter \
    --with-x-toolkit=no \
    --with-xpm=no \
    --with-jpeg=no \
    --with-png=no \
    --with-gif=no \
    --with-tiff=no \
    --with-mailutils=no \
    --with-pop=no
RUN make -j $(nproc)
RUN make install

WORKDIR /tree-sitter-module
RUN git clone --depth 1 https://github.com/casouri/tree-sitter-module /tree-sitter-module
RUN ./batch.sh
RUN mkdir -p /root/.config/emacs/
RUN cp -r /tree-sitter-module/dist /$HOME/.config/emacs/tree-sitter

RUN mkdir -p /$HOME/.local/bin
RUN git clone --depth 1 https://github.com/cask/cask /cask
RUN make -C /cask install

ENV PATH /root/.local/bin:$PATH

WORKDIR /app

# Local Variables:
# compile-command: "docker build -t martini97/emacs:29 ./29"
# End:
