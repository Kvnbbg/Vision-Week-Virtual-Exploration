# Use the official Flutter image
FROM cirrusci/flutter:stable

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Run flutter dependencies installation
RUN flutter pub get

# Expose the port the app runs on
EXPOSE 8080

# Define the entry point command
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080"]
