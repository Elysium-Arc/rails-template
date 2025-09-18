# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application Overview

This is a Rails 8 application called "Pulsar" using modern Rails stack with:
- Authentication system with session-based login
- Multi-language support (English, French, Arabic)
- ViewComponent-based UI architecture
- Hotwire (Turbo + Stimulus) for dynamic interactions
- RSpec for testing
- Tailwind CSS with DaisyUI for styling

## Key Development Commands

### Rails Commands
```bash
# Start development server
./bin/rails server

# Rails console
./bin/rails console

# Database operations
./bin/rails db:create
./bin/rails db:migrate
./bin/rails db:seed

# Generate new resources
./bin/rails generate controller Name action1 action2
./bin/rails generate model ModelName field:type
./bin/rails generate component ComponentName
```

### JavaScript/CSS Build
```bash
# Build JavaScript for development
npm run build-dev

# Build JavaScript for production
npm run build

# Build CSS
npm run build:css
```

### Testing
```bash
# Run all tests
./bin/rspec

# Run specific test file
./bin/rspec spec/models/user_spec.rb

# Run tests with coverage
COVERAGE=true ./bin/rspec
```

### Development Tools
```bash
# Code linting
./bin/rubocop

# Security scanning
./bin/brakeman

# Database analysis
./bin/rails active_record_doctor
```

## Architecture Overview

### Authentication & Authorization
- Custom authentication system using `Authentication` concern in controllers
- Session management with `Session` model and `Current` class for request-scoped user
- Pundit for authorization policies
- Password reset functionality via `PasswordsController`

### Component Architecture
- All UI components inherit from `BaseComponent` (app/components/base_component.rb)
- ViewComponent-based architecture with reusable components:
  - `TopbarComponent`, `SidebarComponent` - Layout components
  - `DataTableComponent`, `TableComponent` - Data display
  - `FormComponent`, `ModalComponent` - Interactive elements
  - `FlashComponent` - User feedback messages

### Filtering & Search
- `FilterableIndex` concern for index pages with filtering
- `FilterBuilder` service for constructing queries
- `FilterComponent` for UI filter controls
- Session-based filter persistence with TTL

### Internationalization
- Supports English, French, and Arabic
- Locale routing with scope `(:locale)`
- I18n tasks for translation management

### Frontend Stack
- Hotwire (Turbo + Stimulus) for dynamic interactions
- Tailwind CSS v4 with DaisyUI components
- ESBuild for JavaScript bundling
- Icons via `rails_icons` gem

### Key Gems
- `pagy` - Pagination
- `ransack` - Search/filter functionality
- `audited` - Model auditing
- `goldiloader` - Automatic eager loading
- `hashid-rails` - Obfuscated IDs
- `turbo_power` - Enhanced Turbo Streams

## Testing Structure
- RSpec with comprehensive test suite
- Factory Bot for test data generation
- Database cleaner for test isolation
- Component testing for ViewComponents
- Shoulda matchers for model validations
- SimpleCov for code coverage reporting

## File Organization Patterns
- Models inherit from `ApplicationRecord`
- Controllers include `Authentication` concern and use Pundit
- Components inherit from `BaseComponent` for consistent helper access
- Services in `app/services/` for complex business logic
- Seeding services in `app/services/seeding/`

## Conventions
- Use RESTful routing patterns
- Follow Rails naming conventions
- Components use descriptive names with `_component.rb` suffix
- Authentication via session-based `Current.user` pattern
- Flash messages use Turbo Stream updates