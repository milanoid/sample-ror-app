# Docker CI Build Instructions

This document describes how to use the Docker CI container to run builds locally, replicating the SemaphoreCI environment.

## Building the CI Image

Build the Docker image from Dockerfile.ci:

```bash
docker build -f Dockerfile.ci -t sample-ror-app-ci:latest .
```

## Environment Details

The CI image includes:
- **OS**: Ubuntu 20.04 (matching SemaphoreCI)
- **Ruby**: 3.4.8 (from .ruby-version)
- **Bundler**: 2.7.2
- **Node.js**: 20.20.0 (LTS)
- **Yarn**: 1.22.22 (via corepack)
- **GCC**: 9.4.0 (set as default compiler)
- **Additional tools**: Git, SQLite3, build-essential, libvips (for image processing)

## Running CI Builds

### Full CI Pipeline (Build + Tests)

Run the complete build and test suite:

```bash
docker run --rm \
  -v $(pwd):/app \
  -w /app \
  -e RAILS_ENV=test \
  sample-ror-app-ci:latest \
  bash -c "
    bundle config set --local deployment 'true' && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install && \
    bundle exec yarn install --check-files && \
    bundle exec rake assets:precompile && \
    bundle exec cucumber --format junit --out cucumber.xml && \
    bundle exec rspec --format RspecJunitFormatter --out rspec.xml
  "
```

### Interactive Shell

Get an interactive shell for manual testing or debugging:

```bash
docker run -it --rm \
  -v $(pwd):/app \
  -w /app \
  -e RAILS_ENV=test \
  sample-ror-app-ci:latest \
  bash
```

Inside the container, you can run commands manually:

```bash
# Configure bundler
bundle config set --local deployment 'true'
bundle config set --local path 'vendor/bundle'

# Install dependencies
bundle install

# Install JavaScript dependencies
bundle exec yarn install --check-files

# Precompile assets
bundle exec rake assets:precompile

# Run specific tests
bundle exec cucumber --format junit --out cucumber.xml
bundle exec rspec --format RspecJunitFormatter --out rspec.xml
```

### Run Only Cucumber Tests

```bash
docker run --rm \
  -v $(pwd):/app \
  -w /app \
  -e RAILS_ENV=test \
  -e TEST_TYPE=cucumber \
  sample-ror-app-ci:latest \
  bash -c "
    bundle config set --local deployment 'true' && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install && \
    bundle exec yarn install --check-files && \
    bundle exec rake assets:precompile && \
    bundle exec cucumber --format junit --out cucumber.xml
  "
```

### Run Only RSpec Tests

```bash
docker run --rm \
  -v $(pwd):/app \
  -w /app \
  -e RAILS_ENV=test \
  -e TEST_TYPE=rspec \
  sample-ror-app-ci:latest \
  bash -c "
    bundle config set --local deployment 'true' && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install && \
    bundle exec yarn install --check-files && \
    bundle exec rake assets:precompile && \
    bundle exec rspec --format RspecJunitFormatter --out rspec.xml
  "
```

## Test Results

Test results are written to your project directory:
- **Cucumber**: `cucumber.xml/TEST-features-*.xml` (directory with XML files)
- **RSpec**: `rspec.xml` (single XML file)

## Mounting Secrets (Optional)

If your application requires Rails master key or other secrets:

```bash
docker run --rm \
  -v $(pwd):/app \
  -v /path/to/master.key:/app/config/master.key:ro \
  -w /app \
  -e RAILS_ENV=test \
  sample-ror-app-ci:latest \
  bash -c "..."
```

## Notes

- The image does **not** include project-specific dependencies (gems, npm packages)
- Dependencies are installed at build time using mounted volumes
- The `vendor/bundle` directory is created in your project during `bundle install`
- Bundle runs in deployment mode matching the SemaphoreCI configuration
- The container runs as root by default (you may see bundler warnings, but this is safe in a container)

## Differences from SemaphoreCI

| Feature | SemaphoreCI | Docker Container |
|---------|-------------|------------------|
| **Caching** | Uses `cache restore/store` | Uses Docker layer caching + volume mounts |
| **Secrets** | Automatic via secrets config | Manual mounting via `-v` flag |
| **Test Results** | Published via `test-results` command | XML files written to project directory |
| **Node.js** | Installed via nvm | Pre-installed via NodeSource |
| **Checkout** | Automatic via `checkout` command | Manual via volume mount (`-v $(pwd):/app`) |

## Troubleshooting

### Bundle warnings about running as root
This is safe to ignore in containers. If you want to avoid the warning, add a non-root user to the Dockerfile.

### Permission issues with vendor/bundle
The container runs as root, so files in `vendor/bundle` will be owned by root. Run `sudo chown -R $USER:$USER vendor/bundle` on your host if needed.

### Out of date lockfile
If you see bundler version mismatch, the container will automatically install the correct version and retry.
