# ------------------- Stage 1: Build Stage ------------------------------
FROM node:21 AS frontend-builder

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy all source code
COPY . .

# Build the app for production
RUN npm run build

# ------------------- Stage 2: NGINX Stage ------------------------------
FROM nginx:alpine

# Copy build output to Nginx HTML directory
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

# Expose port 80 for web access
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
