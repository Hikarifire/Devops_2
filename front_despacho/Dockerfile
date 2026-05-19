

FROM node:20-alpine AS builder
#RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /build
COPY package*.json ./
RUN npm install
    # Instalar dependencias con pnpm
#RUN pnpm install --frozen-lockfile --ignore-scripts
    # Deshabilitar scripts postinstall para evitar problemas con Husky
#RUN pnpm config set ignore-scripts true
COPY . .
RUN npm run build


FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /build/dist /usr/share/nginx/html
EXPOSE 80


