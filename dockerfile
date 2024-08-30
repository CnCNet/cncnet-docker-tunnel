# Start with the Ubuntu base image
FROM ubuntu:latest

# Install Common Software Properties
RUN apt-get update && \
        apt-get install -y software-properties-common

# add extra repository for backports
RUN add-apt-repository ppa:dotnet/backports -y

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y wget tar dotnet-sdk-6.0 dotnet-sdk-8.0 libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Fix "No usable version of libssl was found" .NET Core error
# .NET Core 3.1 only works with OpenSSL 1.x, but Ubuntu 22.04 LTS comes with much newer OpenSSL 3.0
# Package URL taken from https://gist.github.com/joulgs/c8a85bb462f48ffc2044dd878ecaa786
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb &&\
dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb

# Set the working directory
WORKDIR /app

# Download and extract the tarzip file
RUN wget -c https://downloads.cncnet.org/cncnet-server.tgz -O - | tar -xz

# Change perms to make cncnet-sever executable
RUN chmod +x /app/cncnet-server

# Set environment variable to disable globalization support
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true


# Expose the required ports
EXPOSE 50000/tcp 50000/udp 50001/tcp 50001/udp 8054/udp 3478/udp

# Start the tunnel server when the container launches
CMD  ./cncnet-server --name "My CnCNet tunnel" --maxclients 200 --port 50001 --portv2 50000 > cncnet-server.log 2>&1 && tail -f cncnet-server.log
