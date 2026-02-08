# Minimal Rails App for CI/CD Testing

A minimal Ruby on Rails application designed for testing CI/CD pipelines. This app includes a simple Post scaffold with full CRUD operations, tests, and Semaphore CI configuration.

## Features

- Rails 8.1.2 with Ruby 3.4
- Single Post model (title:string, body:text)
- Full scaffold with views and controllers
- SQLite database (zero configuration)
- RSpec and Cucumber test suites
- RuboCop and Brakeman linting
- Semaphore CI pipeline configuration

## Running Tests

### RSpec (Unit/Model Tests)
```bash
bundle exec rspec
```

### Cucumber (Acceptance Tests)
```bash
bundle exec cucumber
```

### Run All Tests
```bash
bundle exec rspec && bundle exec cucumber
```

## Running Locally with Docker

Since this app is designed for CI/CD testing, you can run it entirely with Docker:

### Run RSpec Tests
```bash
docker run --rm -v "$(pwd):/app" -w /app ruby:3.4.2 bash -c "bundle install && bundle exec rspec"
```

### Run Cucumber Tests
```bash
docker run --rm -v "$(pwd):/app" -w /app ruby:3.4.2 bash -c "bundle install && bundle exec cucumber"
```

### Run Linting
```bash
# RuboCop
docker run --rm -v "$(pwd):/app" -w /app ruby:3.4.2 bash -c "bundle install && bundle exec rubocop"

# Brakeman security check
docker run --rm -v "$(pwd):/app" -w /app ruby:3.4.2 bash -c "bundle install && bundle exec brakeman --no-pager"
```

### Start the Server (Optional)
```bash
docker run --rm -v "$(pwd):/app" -w /app -p 3000:3000 ruby:3.4.2 bash -c "bundle install && bin/rails db:migrate && bin/rails server -b 0.0.0.0"
```

Then visit http://localhost:3000

## CI/CD Configuration

### Semaphore CI

The `.semaphore/semaphore.yml` file contains the complete pipeline configuration:

1. **Setup Block** - Installs dependencies and caches gems
2. **Tests Block** - Runs database migrations and the full test suite
3. **Linting Block** - Runs RuboCop and Brakeman security checks

To use with Semaphore CI:
1. Connect your repository to Semaphore
2. The pipeline will automatically use the configuration file
3. All tests and linting will run on every push

## Database

- Uses SQLite3 (included, no setup needed)
- Test database is created automatically in CI
- Migrations run automatically before tests

## What Gets Tested

- **RSpec Model Tests**: Post model validations and functionality
- **Cucumber Features**: Acceptance tests for user interactions
- **Code Quality**: RuboCop style checks
- **Security**: Brakeman security vulnerability scanning

## Minimal by Design

This app intentionally keeps dependencies and features minimal to:
- Speed up CI/CD pipeline execution
- Reduce maintenance overhead
- Focus on pipeline testing, not application complexity
- Serve as a quick smoke test for infrastructure changes
