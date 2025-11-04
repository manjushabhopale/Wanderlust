# ------------------- Stage 1: Build Stage ------------------------------
FROM node:21 AS frontend-builder

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy all source code
COPY . .

# ------------------- Stage 2: NGINX Stage ------------------------------
FROM node:21-slim

WORKDIR /app

# Copy build output to Nginx HTML directory
COPY --from=frontend-builder /app .

# Copy the .env.sample file to .env.local
COPY .env.docker .env.local

# Expose port 80 for web access
EXPOSE 5173

# Start Nginx
CMD ["npm", "run", "dev", "--", "--host"]
