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
    wget

# Run as root
USER root

# Install supervisor
RUN apt-get install -y supervisor && \
	mkdir -p /etc/supervisor/conf.d/ && \
	mkdir -p /var/log/supervisor/

# Copy supervisor configuration file
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Setup supervisor permissions
RUN touch /var/log/supervisor/rust.out.log && touch /var/log/supervisor/rust.err.log
RUN chown -R root:root /var/log/supervisor/rust.*.log

# Install SteamCMD
RUN mkdir -p /steamcmd/rust && \
	curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx

# Setup Rust symlinks
RUN mkdir -p /rust_data/backup && ln -s /rust_data/backup /steamcmd/rust/backup
RUN mkdir -p /rust_data/config && ln -s /rust_data/config /steamcmd/rust/config
RUN mkdir -p /rust_data/server && ln -s /rust_data/server /steamcmd/rust/server

# Enable the Rust data volume
VOLUME ["/rust_data"]

# Set the current working directory and the current user
WORKDIR /steamcmd

# Install/update Rust from install.txt
ADD install.txt /steamcmd/install.txt
RUN /steamcmd/steamcmd.sh +runscript /steamcmd/install.txt

# Copy Rust startup script
ADD start_rust.sh /steamcmd/rust/start.sh

# Expose necessary ports
EXPOSE 28015
EXPOSE 28016

# Setup default environment variables for the server
ENV RUST_SERVER_STARTUP_ARGUMENTS "-batchmode -load -logfile /rust_data/rust.log"

# Start supervisord
CMD supervisord -n -c /etc/supervisor/supervisord.conf
