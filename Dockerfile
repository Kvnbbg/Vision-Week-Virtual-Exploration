# Stage 1: Build the Flutter app
FROM cirrusci/flutter:stable AS build-stage

# Set the working directory
WORKDIR /app

# Copy only the pubspec files to install dependencies separately
COPY pubspec.yaml pubspec.lock ./

# Install dependencies and remove unnecessary cache to reduce image size
RUN flutter pub get && \
    rm -rf ~/.pub-cache/*

# Copy the rest of the app code
COPY . .

# Build the Flutter web app and remove intermediate build artifacts
RUN flutter build web && \
    rm -rf /app/.dart_tool /app/build/flutter_assets /app/test /app/docs

# Stage 2: Create a minimal runtime image
FROM cirrusci/flutter:stable AS runtime-stage

# Set the working directory
WORKDIR /app

# Copy only the build output from the build stage
COPY --from=build-stage /app/build/web /app/web

# Expose the port the app will run on
EXPOSE 8080

# Start the web server using the built files
CMD ["flutter", "serve", "--web-port", "8080", "--web-hostname", "0.0.0.0", "--no-sound-null-safety"]
