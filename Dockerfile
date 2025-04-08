FROM node:alpine

WORKDIR /app

# Copy everything into /app
COPY . .

RUN npm install -g docsify-cli

# Switch to /app/docs as the working directory
WORKDIR /app/docs

EXPOSE 3000

CMD ["docsify", "serve", "."]
