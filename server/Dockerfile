#An Ubuntu 16.04 image with Swift preinstalled
FROM seriyvolk83/swift:4.2.1

# Copy application
COPY . /app

# Build application
RUN swift --version
RUN swift build -c release --package-path /app/SampleServer --build-path /app/SampleServer/.build

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run the server when container is launched
CMD ["/app/SampleServer/.build/release/SampleServer"]
