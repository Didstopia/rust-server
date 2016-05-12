FROM ubuntu:16.04

MAINTAINER galaxxius

# Run a quick apt-get update/upgrade
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y --purge

# Install dependencies, mainly for SteamCMD
RUN apt-get install -y \
    ca-certificates \
    software-properties-common \
    python-software-properties \
    lib32gcc1 \
    libstdc++6 \
    curl \
    wget \
    bsdtar \
    nginx \
    build-essential

# Run as root
USER root

# Setup the default timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Remove default nginx stuff
RUN rm -fr /usr/share/nginx/html/* && \
	rm -fr /etc/nginx/sites-available/* && \
	rm -fr /etc/nginx/sites-enabled/*

# Install webrcon
COPY nginx_rcon.conf /etc/nginx/nginx.conf
RUN curl -sL https://github.com/Didstopia/webrcon/archive/gh-pages.zip | bsdtar -xvf- -C /tmp && \
	mv /tmp/webrcon-gh-pages/* /usr/share/nginx/html/ && \
	rm -fr /tmp/webrcon-gh-pages

# Customize the webrcon package to fit our needs
ADD fix_conn.sh /tmp/fix_conn.sh

# Create and set the steamcmd folder as a volume
RUN mkdir -p /steamcmd/rust
VOLUME ["/steamcmd/rust"]

# Add the steamcmd installation script
ADD install.txt /install.txt

# Copy the Rust startup script
ADD start_rust.sh /start.sh

# Setup proper shutdown support
RUN curl -sL https://deb.nodesource.com/setup_5.x | bash -
RUN apt-get install -y nodejs
ADD shutdown_app/ /shutdown_app/
WORKDIR /shutdown_app
RUN npm install
WORKDIR /

# Expose necessary ports
EXPOSE 8080
EXPOSE 28015
EXPOSE 28016

# Setup default environment variables for the server
ENV RUST_SERVER_STARTUP_ARGUMENTS "-batchmode -load -logfile /dev/stdout +server.secure 1"
ENV RUST_SERVER_IDENTITY "dockerust"
ENV RUST_SERVER_SEED "1337"
ENV RUST_SERVER_NAME "dockerust"
ENV RUST_SERVER_DESCRIPTION "This is a Rust server running inside a Docker container!"
ENV RUST_SERVER_URL "https://hub.docker.com/r/didstopia/rust-server/"
ENV RUST_SERVER_BANNER_URL ""
ENV RUST_RCON_WEB "1"
ENV RUST_RCON_PORT "28016"
ENV RUST_RCON_PASSWORD "otherpw"
ENV RUST_RESPAWN_ON_RESTART "0"
ENV RUST_DISABLE_AUTO_UPDATE "0"

# Start the server
ENTRYPOINT ["./start.sh"]
