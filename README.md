## Running the Project with Docker

This project uses Docker to containerize both the frontend (TypeScript-based) and backend (JavaScript/Node.js) services. Below are the specific instructions and requirements for running the project using Docker Compose.

### Project-Specific Docker Requirements
- **Node.js Version:** Both services require Node.js version `22.13.1` (as set by the `NODE_VERSION` build argument in the Dockerfiles).
- **Dependencies:**
  - Frontend: Installs dependencies via `npm ci`, builds the TypeScript project, and prunes dev dependencies for production.
  - Backend: Installs only production dependencies via `npm ci --production`.
- **Non-root User:** Both containers create and run as a non-root user (`appuser` in `appgroup`).
- **Memory Limit:** Both services set `NODE_OPTIONS="--max-old-space-size=4096"` for increased memory allocation.

### Environment Variables
- No required environment variables are set by default in the Dockerfiles or Compose file. If you need to provide environment variables, uncomment and use the `env_file` lines in the `docker-compose.yml` for each service.

### Build and Run Instructions
1. **Build and Start Services:**
   ```sh
   docker compose up --build
   ```
   This will build and start both the frontend and backend containers.

2. **Custom Configuration:**
   - If you have environment variables, create `.env` files in the project root and/or `./backend` directory, then uncomment the `env_file` lines in `docker-compose.yml`.
   - If your frontend serves on a specific port (e.g., 3000 or 5173), uncomment and adjust the `ports` section for `typescript-root` in `docker-compose.yml`.
   - For inter-service communication, all services are on the default Docker network.

### Ports
- **Backend (`javascript-backend`):**
  - Exposes port `3000` (`ports: - "3000:3000"` in Compose file).
- **Frontend (`typescript-root`):**
  - No port is exposed by default. Uncomment and configure the `ports` section in `docker-compose.yml` if your frontend needs to be accessed directly.

### Notes
- The backend service starts with `node server.cjs` and expects to listen on port 3000.
- The frontend service starts with `npm start` and runs the built code from the `/dist` directory.
- Both services are set to restart unless stopped and use Docker's `init` for proper signal handling.

Refer to the `docker-compose.yml` and Dockerfiles for further customization as needed for your development or production environment.