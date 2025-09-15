FROM ruby:3.3.6-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    pkg-config \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

WORKDIR /app

# Set bundle path
ENV BUNDLE_PATH="/usr/local/bundle"

# Copy Gemfiles
COPY Gemfile Gemfile.lock ./

# Install gems (force reinstall to ensure all gems are installed)
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Set environment
ENV RAILS_ENV=development

# Create binstubs
RUN bundle binstubs --all

# Expose port
EXPOSE 3000

# Start server
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
