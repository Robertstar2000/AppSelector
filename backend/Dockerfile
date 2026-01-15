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

# Make entrypoint script executable (if it exists)
RUN if [ -f backend/entrypoint.sh ]; then chmod +x backend/entrypoint.sh; else echo "backend/entrypoint.sh not found"; fi

# Set environment variables for production
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Create a non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Expose port (change if your app uses a different port)
EXPOSE 3000

# Use entrypoint script
ENTRYPOINT ["backend/entrypoint.sh"]
CMD ["node backend/server.cjs"]
