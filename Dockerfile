# --------------------------------------------------------------
# Dockerfile for zone-import tool – portable development container
# --------------------------------------------------------------
#
# This Dockerfile builds a container image for the zone-import DNS tool.
# It ensures all dependencies are installed and the tool is ready to run
# in any environment supporting Docker. The image is based on Debian,
# matching the original install script's assumptions.
#
# Usage:
#   docker build -t zone-import .
#   docker run --rm -it zone-import [zone-import arguments]
#
# --------------------------------------------------------------

# Use official Python 3 image (Debian-based)
FROM python:3.11-slim

# Set environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
# - dnsutils: provides dig for DNS queries
# - curl: for troubleshooting/networking
RUN apt-get update && \
    apt-get install -y --no-install-recommends dnsutils curl && \
    rm -rf /var/lib/apt/lists/*

# Create a working directory for the tool
WORKDIR /opt/zone-import

# Copy the zone-import Python script into the container
# (We will extract this from the install script during build)
COPY zone-import.py /usr/local/bin/zone-import

# Make the script executable
RUN chmod +x /usr/local/bin/zone-import

# Install required Python libraries
RUN pip install --no-cache-dir dnspython requests

# Set default entrypoint to the tool
ENTRYPOINT ["/usr/local/bin/zone-import"]

# By default, run without arguments (interactive wizard)
CMD []

# --------------------------------------------------------------
# End of Dockerfile
# --------------------------------------------------------------
