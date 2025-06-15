# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KokushiEX Next is a modern web application for Physical Therapist National Examination practice in Japan, built as a Docker-containerized microservices architecture with separate frontend and backend services.

## Architecture

**Multi-service Docker setup:**
- **Frontend**: Next.js 15.3.3 with React 19, TypeScript, Tailwind CSS 4
- **Backend**: Rails 7.2 API-only application with Ruby 3.3.6
- **Database**: PostgreSQL 16

**Service Communication:**
- Frontend runs on port 3000, backend on port 3001 (mapped from container port 3000)
- Next.js rewrites `/api/*` requests to `http://backend:3000/api/*` via Docker network
- Database accessible at localhost:5432 for local development

## Development Commands

### Docker Operations
```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d frontend
docker-compose up -d backend

# Rebuild service after changes
docker-compose build frontend
docker-compose build backend

# View logs
docker-compose logs frontend
docker-compose logs backend
docker-compose logs db

# Stop all services
docker-compose down
```

### Frontend (Next.js)
```bash
# Inside frontend/ directory or via Docker
npm run dev          # Start development server with Turbopack
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
```

### Backend (Rails)
```bash
# Via Docker (recommended)
docker-compose exec backend rails console
docker-compose exec backend rails db:migrate
docker-compose exec backend rails db:seed
docker-compose exec backend bundle exec rspec

# Database operations
docker-compose exec backend rails db:create
docker-compose exec backend rails db:reset
```

### Linting and Quality
```bash
# Frontend
docker-compose exec frontend npm run lint

# Backend
docker-compose exec backend bundle exec rubocop
docker-compose exec backend bundle exec brakeman
```

## Key Configuration

**API Routing**: Next.js automatically proxies `/api/*` requests to the Rails backend through Docker networking. The backend exposes API endpoints under `/api/` namespace.

**Database**: Uses environment variable `DATABASE_HOST` to switch between `localhost` (local) and `db` (Docker). Connection configured in `backend/config/database.yml`.

**Node.js Version**: Locked to 22.15.0 across `.node-version`, `package.json` engines, and Docker image.

**Environment Variables**:
- `NEXT_PUBLIC_API_URL`: Frontend API base URL 
- `DATABASE_HOST`: Database hostname (set to `db` in Docker)
- `RAILS_ENV`: Rails environment mode

## Testing API Integration

A test component exists at `frontend/components/api-test.tsx` that can verify frontend-backend connectivity via the `/api/health` endpoint.

## Important Files

- `docker-compose.yml`: Service orchestration and networking
- `frontend/next.config.ts`: API proxy configuration and image handling
- `backend/config/database.yml`: Database connection settings
- `backend/config/routes.rb`: API route definitions
- `.node-version`: Node.js version specification