FROM didstopia/base:nodejs-steamcmd-ubuntu-16.04

MAINTAINER Didstopia <support@didstopia.com>

# Fix apt-get warnings
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx \
    expect \
    tcl \
    libgdiplus && \
    rm -rf /var/lib/apt/lists/*

# Remove default nginx stuff
RUN rm -fr /usr/share/nginx/html/* && \
	rm -fr /etc/nginx/sites-available/* && \
	rm -fr /etc/nginx/sites-enabled/*

# Install webrcon (specific commit)
COPY nginx_rcon.conf /etc/nginx/nginx.conf
RUN curl -sL https://github.com/Facepunch/webrcon/archive/24b0898d86706723d52bb4db8559d90f7c9e069b.zip | bsdtar -xvf- -C /tmp && \
	mv /tmp/webrcon-24b0898d86706723d52bb4db8559d90f7c9e069b/* /usr/share/nginx/html/ && \
	rm -fr /tmp/webrcon-24b0898d86706723d52bb4db8559d90f7c9e069b

# Customize the webrcon package to fit our needs
ADD fix_conn.sh /tmp/fix_conn.sh

# Create and set the steamcmd folder as a volume
RUN mkdir -p /steamcmd/rust
VOLUME ["/steamcmd/rust"]

# Setup proper shutdown support
ADD shutdown_app/ /shutdown_app/
WORKDIR /shutdown_app
RUN npm install

# Setup restart support (for update automation)
ADD restart_app/ /restart_app/
WORKDIR /restart_app
RUN npm install

# Setup scheduling support
ADD scheduler_app/ /scheduler_app/
WORKDIR /scheduler_app
RUN npm install

# Setup rcon command relay app
ADD rcon_app/ /rcon_app/
WORKDIR /rcon_app
RUN npm install
RUN ln -s /rcon_app/app.js /usr/bin/rcon

# Add the steamcmd installation script
ADD install.txt /install.txt

# Copy the Rust startup script
ADD start_rust.sh /start.sh

# Copy the Rust update check script
ADD update_check.sh /update_check.sh

# Copy extra files
COPY README.md LICENSE.md /

# Set the current working directory
WORKDIR /

# Expose necessary ports
EXPOSE 8080
EXPOSE 28015
EXPOSE 28016

# Setup default environment variables for the server
ENV RUST_SERVER_STARTUP_ARGUMENTS "-batchmode -load -nographics +server.secure 1"
ENV RUST_SERVER_IDENTITY "docker"
ENV RUST_SERVER_SEED "12345"
ENV RUST_SERVER_NAME "Rust Server [DOCKER]"
ENV RUST_SERVER_DESCRIPTION "This is a Rust server running inside a Docker container!"
ENV RUST_SERVER_URL "https://hub.docker.com/r/didstopia/rust-server/"
ENV RUST_SERVER_BANNER_URL ""
ENV RUST_RCON_WEB "1"
ENV RUST_RCON_PORT "28016"
ENV RUST_RCON_PASSWORD "docker"
ENV RUST_UPDATE_CHECKING "0"
ENV RUST_UPDATE_BRANCH "public"
ENV RUST_START_MODE "0"
ENV RUST_OXIDE_ENABLED "0"
ENV RUST_OXIDE_UPDATE_ON_BOOT "1"
ENV RUST_SERVER_WORLDSIZE "4000"
ENV RUST_SERVER_MAXPLAYERS "500"
ENV RUST_SERVER_SAVE_INTERVAL "600"

# Start the server
ENTRYPOINT ["./start.sh"]
