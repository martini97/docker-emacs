FROM ubuntu:22.04 AS emacs-builder

WORKDIR /emacs

ARG EMACS_BRANCH=master
ENV DEBIAN_FRONTEND=noninteractive
ENV CC=/usr/bin/gcc-10
ENV CXX=/usr/bin/gcc-10
ENV LD_LIBRARY_PATH=/usr/local/lib/
ENV PATH=/root/.local/bin:$PATH

RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list
RUN apt update >/dev/null
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

RUN rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --single-branch --branch $EMACS_BRANCH \
    git://git.savannah.gnu.org/emacs.git /emacs
RUN ./autogen.sh
RUN ./configure \
    --prefix=/opt/emacs \
    --with-native-compilation=aot \
    --with-tree-sitter \
    --with-x-toolkit=no \
    --with-xpm=no \
    --with-jpeg=no \
    --with-png=no \
    --with-gif=no \
    --with-tiff=no \
    --with-mailutils=no \
    --with-pop=no \
    --without-x
RUN make -j $(nproc)
RUN make install

FROM ubuntu:22.04 as cask-builder

WORKDIR /cask

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update >/dev/null
RUN apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    git \
    gnutls-bin \
    python3 \
    build-essential \
    libasound2 \
    libdbus-1-3 \
    libxml2 \
    libgpm2 \
    liblcms2-2 \
    libjansson-dev \
    libjansson4 \
    libgccjit-10-dev \
    libtree-sitter-dev \
    gcc-10

RUN rm -rf /var/lib/apt/lists/*

ENV PATH /opt/emacs/bin:$PATH
COPY --from=emacs-builder /opt/emacs /opt/emacs

RUN mkdir -p /root/.local/bin
RUN git clone --depth 1 https://github.com/cask/cask /cask
RUN make install

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update >/dev/null
RUN apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    build-essential \
    libasound2 \
    libdbus-1-3 \
    libxml2 \
    libgpm2 \
    liblcms2-2 \
    libjansson-dev \
    libjansson4 \
    libgccjit-10-dev \
    libtree-sitter-dev \
    gcc-10 \
    git

RUN rm -rf /var/lib/apt/lists/*

ENV PATH /opt/emacs/bin:$PATH
COPY --from=emacs-builder /opt/emacs /opt/emacs

ENV PATH /root/.local/bin:$PATH
COPY --from=cask-builder /root/.emacs.d /root/.emacs.d
COPY --from=cask-builder /root/.local /root/.local

WORKDIR /app

# Local Variables:
# compile-command: "make build"
# End:
