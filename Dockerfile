# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Create a non-root user
RUN useradd -m -s /bin/bash flutter
USER flutter

# Set working directory
WORKDIR /home/flutter/app

# Copy pubspec files
COPY --chown=flutter:flutter pubspec.yaml ./


# Get dependencies
RUN flutter pub get

# Copy source code
COPY --chown=flutter:flutter . .

# Build for web
RUN flutter build web --release

# Production stage
FROM nginx:alpine

# Copy built web app to nginx html directory
COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]