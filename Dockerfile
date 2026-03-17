FROM node:22-alpine

# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install --production

# Copy app source
COPY . .

# Expose port (default 3000, can be overridden by env)
EXPOSE 3000

# Set environment variables (optional, can be overridden at runtime)
ENV NODE_ENV=production

# Start the app
CMD ["npm", "start"]