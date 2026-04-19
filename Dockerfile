# Use official nginx image as base
FROM nginx:latest

# Set working directory
WORKDIR /usr/share/nginx/html

# Add custom message to nginx welcome page
RUN echo "<h1>This is nginx server on a linux VM customized by balajigv, under app-project</h1>" > index.html

# Copy any custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
