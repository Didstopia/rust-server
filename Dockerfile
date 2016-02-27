FROM ubuntu:14.04

# Add support for 32-bit architecture
RUN dpkg --add-architecture i386

# Run a quick apt-get update/upgrade
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y

# Install dependencies, mainly for SteamCMD
RUN apt-get install --no-install-recommends -y \
    ca-certificates \
    software-properties-common \
    python-software-properties \
    screen \
    libc6-amd64 \
    Xvfb \
    lib32gcc1 \
    net-tools \
    lib32stdc++6 \
    lib32z1 \
    lib32z1-dev \
    curl \
    wget \
    telnet

# Run as root
USER root

# Install SteamCMD
RUN mkdir -p /steamcmd/rust && \
	curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx

# Create the server directory
RUN mkdir -p /steamcmd/rust/server

# Set the current working directory and the current user
WORKDIR /steamcmd

# Install/update Rust from install.txt
ADD install.txt /steamcmd/install.txt
RUN /steamcmd/steamcmd.sh +runscript /steamcmd/install.txt

# Copy Rust startup script
ADD start_rust.sh /steamcmd/rust/start.sh

# Set the server folder up as a volume
VOLUME ["/steamcmd/rust/server"]

# Expose necessary ports
EXPOSE 28015
EXPOSE 28016

# Setup default environment variables for the server
ENV RUST_SERVER_STARTUP_ARGUMENTS "-batchmode -load -logfile /dev/stdout"
ENV RUST_SERVER_NAME "Rust Server [DOCKER]"
ENV RUST_SERVER_DESCRIPTION "This is a Rust server running inside a Docker container!"
ENV RUST_SERVER_URL "https://hub.docker.com/r/didstopia/rust-server/"
ENV RUST_SERVER_BANNER_URL ""

# Start the server
WORKDIR /steamcmd/rust
CMD bash start.sh
