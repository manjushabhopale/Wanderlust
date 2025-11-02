# Stage 1
FROM node:21 AS backend-builder

# setup the working dir
WORKDIR /app

# code
COPY . .

# packages install
RUN npm i

# tests
RUN npm run test

# Stage 2
FROM node:21-slim
ARG MONGODB_URI
ARG REDIS_URL
ARG VITE_API_PATH

ENV MONGODB_URI=$MONGODB_URI
ENV REDIS_URL=$REDIS_URL
ENV VITE_API_PATH=$VITE_API_PATH

# setup the working dir
WORKDIR /app

# copy the above stage as compressed
COPY --from=backend-builder /app .

COPY .env .env.local

# Port
EXPOSE 5000

# App
CMD ["npm", "start"]
