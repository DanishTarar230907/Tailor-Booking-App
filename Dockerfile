# Stage 1: Build the Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set the working directory
WORKDIR /app

# Clone your specific repository
# Note: Cloning inside Docker is okay, but usually 'COPY . .' is preferred 
# if you are running docker build from within your local project folder.
RUN git clone https://github.com/DanishTarar230907/Tailor-Booking-App.git .

# Fetch dependencies
RUN flutter pub get

# Build the application for the web
RUN flutter build web --release

# Stage 2: Serve the application with Nginx
FROM nginx:alpine

# Copy the built web artifacts from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]