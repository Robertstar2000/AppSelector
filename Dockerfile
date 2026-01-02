# syntax=docker/dockerfile:1
ARG NODE_VERSION=22.13.1

# Build stage
FROM node:${NODE_VERSION}-slim AS builder
WORKDIR /app

# Copy only package.json and package-lock.json for dependency install
COPY --link package.json package-lock.json ./

# Install dependencies with cache
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# Copy the rest of the source files
COPY --link . .

# Build the TypeScript project (assumes a build script is defined)
RUN --mount=type=cache,target=/root/.npm \
    npm run build

# Remove dev dependencies, keep only production
RUN --mount=type=cache,target=/root/.npm \
    npm ci --production

# Production stage
FROM node:${NODE_VERSION}-slim AS final
WORKDIR /app

# Create a non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Copy built app and production dependencies from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/package-lock.json ./

# Install vite for preview command
RUN npm install vite

ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=4096"
USER appuser

# Start the app (serve the built static files)
CMD ["npx", "vite", "preview", "--host", "0.0.0.0", "--port", "3000"]
