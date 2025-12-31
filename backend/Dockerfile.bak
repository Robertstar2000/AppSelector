FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Build the frontend
RUN npm run build

EXPOSE 3001

CMD ["node", "backend/server.cjs"]
