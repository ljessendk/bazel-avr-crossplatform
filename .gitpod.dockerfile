FROM gitpod/workspace-full

RUN sudo apt-get update  && sudo apt-get install -y flex texinfo help2man libtool-bin && sudo rm -rf /var/lib/apt/lists/*
RUN sudo wget -O /usr/local/bin/bazel https://github.com/bazelbuild/bazel/releases/download/7.0.0/bazel_nojdk-7.0.0-linux-x86_64 && sudo chmod 555 /usr/local/bin/bazel
RUN sudo wget -O /usr/local/bin/buildifier https://github.com/bazelbuild/buildtools/releases/download/v6.4.0/buildifier-linux-amd64 && sudo chmod a+x /usr/local/bin/buildifier