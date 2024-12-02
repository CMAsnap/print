# Use the official Ubuntu base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production
ENV NPM_CONFIG_LOGLEVEL=info
ENV NODE_OPTIONS="--enable-source-maps"
ENV DEBUG_MODE=false
ENV ALLOW_HTTP=false
ENV PORT=3000

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    apt-transport-https \
    software-properties-common

# Install NVM
ENV NVM_DIR /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Install Node.js using NVM
RUN . "$NVM_DIR/nvm.sh" && nvm install stable && nvm use stable && nvm alias default stable

# Install Chromium
RUN apt-get update && \
    apt-get install -y chromium-browser

# Set the working directory
WORKDIR /app

# Copy the application code
COPY . .

# Install application dependencies
RUN . "$NVM_DIR/nvm.sh" && nvm use default && npm install

# Expose the application port
EXPOSE $PORT

# Start the application with log forwarding
CMD ["/bin/bash", "-c", ". /root/.nvm/nvm.sh && nvm use default && exec npm start | tee -a /dev/stdout"]
