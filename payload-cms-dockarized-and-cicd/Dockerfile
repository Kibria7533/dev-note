# Use a minimal Node.js base image
FROM node:22.12.0-alpine AS base

# Install dependencies only when needed
FROM base AS deps

# Required for some Node modules
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy lock files and install dependencies using pnpm
COPY package.json pnpm-lock.yaml ./

RUN npm install -g pnpm && pnpm install --frozen-lockfile


# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app

RUN npm install -g pnpm

# Copy app code and node_modules from deps
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build the application
RUN pnpm next build --experimental-build-mode compile

# Production image, copy only necessary files
FROM base AS runner

WORKDIR /app
ENV NODE_ENV production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs \
 && adduser --system --uid 1001 nextjs

# Copy required folders/files for standalone build
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV PORT 3000

# Use standalone output's server.js
CMD ["node", "server.js"]
