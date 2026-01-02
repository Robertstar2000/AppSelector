# syntax=docker/dockerfile:1
ARG NODE_VERSION=22.13.1
FROM node:${NODE_VERSION}-slim AS base
WORKDIR /app

# Copy only package.json and package-lock.json for dependency installation
COPY --link package.json package-lock.json ./

# Install dependencies with cache for faster builds
RUN --mount=type=cache,target=/root/.npm \
    npm ci --production

# Copy application source code
COPY --link . .

# Set environment variables for production
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Create a non-root user and switch to it
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

# Expose port (change if your app uses a different port)
EXPOSE 3000

# Start the application (adjust entrypoint if needed)
CMD ["node", "backend/server.cjs"]
