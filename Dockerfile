FROM didstopia/base:nodejs-12-steamcmd-ubuntu-18.04

LABEL maintainer="Didstopia <support@didstopia.com>"

# Fix apt-get warnings
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        expect \
        tcl \
	libsdl2-2.0-0:i386 \
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

# Create the volume directories
RUN mkdir -p /steamcmd/rust /usr/share/nginx/html /var/log/nginx

# Setup proper shutdown support
ADD shutdown_app/ /app/shutdown_app/
WORKDIR /app/shutdown_app
RUN npm install

# Setup restart support (for update automation)
ADD restart_app/ /app/restart_app/
WORKDIR /app/restart_app
RUN npm install

# Setup scheduling support
ADD scheduler_app/ /app/scheduler_app/
WORKDIR /app/scheduler_app
RUN npm install

# Setup rcon command relay app
ADD rcon_app/ /app/rcon_app/
WORKDIR /app/rcon_app
RUN npm install
RUN ln -s /app/rcon_app/app.js /usr/bin/rcon

# Add the steamcmd installation script
ADD install.txt /app/install.txt

# Copy the Rust startup script
ADD start_rust.sh /app/start.sh

# Copy the Rust update check script
ADD update_check.sh /app/update_check.sh

# Copy extra files
COPY README.md LICENSE.md /app/

# Set the current working directory
WORKDIR /

# Fix permissions
RUN chown -R 1000:1000 \
    /steamcmd \
    /app \
    /usr/share/nginx/html \
    /var/log/nginx

# Run as a non-root user by default
ENV PGID 1000
ENV PUID 1000

# Expose necessary ports
EXPOSE 8080
EXPOSE 28015
EXPOSE 28016
EXPOSE 28082

# Setup default environment variables for the server
ENV RUST_SERVER_STARTUP_ARGUMENTS "-batchmode -load -nographics +server.secure 1"
ENV RUST_SERVER_IDENTITY "docker"
ENV RUST_SERVER_PORT ""
ENV RUST_SERVER_SEED "12345"
ENV RUST_SERVER_NAME "Rust Server [DOCKER]"
ENV RUST_SERVER_DESCRIPTION "This is a Rust server running inside a Docker container!"
ENV RUST_SERVER_URL "https://hub.docker.com/r/didstopia/rust-server/"
ENV RUST_SERVER_BANNER_URL ""
ENV RUST_RCON_WEB "1"
ENV RUST_RCON_PORT "28016"
ENV RUST_RCON_PASSWORD "docker"
ENV RUST_APP_PORT "28082"
ENV RUST_UPDATE_CHECKING "0"
ENV RUST_UPDATE_BRANCH "public"
ENV RUST_START_MODE "0"
ENV RUST_OXIDE_ENABLED "0"
ENV RUST_OXIDE_UPDATE_ON_BOOT "1"
ENV RUST_SERVER_WORLDSIZE "3500"
ENV RUST_SERVER_MAXPLAYERS "500"
ENV RUST_SERVER_SAVE_INTERVAL "600"

# Define directories to take ownership of
ENV CHOWN_DIRS "/app,/steamcmd,/usr/share/nginx/html,/var/log/nginx"

# Expose the volumes
# VOLUME [ "/steamcmd/rust" ]

# Start the server
CMD [ "bash", "/app/start.sh"]
