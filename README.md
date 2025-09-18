# Rails Application Template

A modern Rails 8 application template with authentication, multi-language support, and a comprehensive component-based UI architecture.

## 🚀 Features

### Core Features
- **Authentication System**: Session-based authentication with secure password management
- **Multi-language Support**: English, French, and Arabic with locale routing
- **Component Architecture**: ViewComponent-based UI with reusable components
- **Hotwire Integration**: Turbo + Stimulus for dynamic interactions
- **Modern Frontend**: Tailwind CSS v4 with DaisyUI components
- **Comprehensive Testing**: RSpec with coverage reporting
- **Search & Filtering**: Advanced filtering with ransack and session persistence
- **Auditing**: Model auditing with goldiloader for performance
- **Security**: Built-in security best practices with brakeman integration

### UI Components
- **Layout**: Topbar, Sidebar, Breadcrumb navigation
- **Data Display**: DataTable, Table components with pagination
- **Forms**: FormComponent with validation and error handling
- **Interactive**: Modal, Dropdown, Flash components
- **Theme**: Dark/light mode toggle with ThemeToggleComponent

### Development Tools
- **Code Quality**: RuboCop, Overcommit hooks
- **Security**: Brakeman scanning
- **Database**: ActiveRecord doctor for database health
- **Performance**: Goldiloader for automatic eager loading
- **Internationalization**: I18n tasks for translation management

## 📋 Prerequisites

- Ruby 3.3.0 (specified in `.ruby-version`)
- Rails 8.0
- Node.js for JavaScript build tools
- PostgreSQL (recommended) or other supported database

## 🛠️ Template Usage

### 1. Generate a New Application

Use the included template generation script to create a new Rails application:

```bash
# Clone this template repository
git clone <repository-url> my-new-app
cd my-new-app

# Generate the application with your desired name
ruby generate_from_template.rb MyApp

# The script will:
# - Replace all __APP_NAME__ placeholders with "MyApp"
# - Update configuration files
# - Set up the basic application structure
```

### 2. Alternative: Manual Setup

If you prefer manual setup or want to use this as a starting point:

1. **Copy the template files** to your new application directory
2. **Update application name** in configuration files:
   - `config/application.rb`
   - `package.json`
   - Any other files containing `__APP_NAME__` placeholders
3. **Update database configuration** in `config/database.yml`
4. **Install dependencies**:
   ```bash
   bundle install
   npm install
   ```

### 3. Initial Setup

After generating your application:

```bash
# Database setup
./bin/rails db:create
./bin/rails db:migrate
./bin/rails db:seed

# Start the development server
./bin/rails server
```

## 🎯 Application Structure

### Authentication & Authorization
- **Models**: `User`, `Session`, `Current` (request-scoped user)
- **Controllers**: `SessionsController`, `PasswordsController`
- **Concerns**: `Authentication` for protected controllers
- **Policies**: Pundit policies for authorization
- **Features**: Password reset, session management, secure authentication

### Component Architecture
All UI components inherit from `BaseComponent` (`app/components/base_component.rb`):

- **Layout Components**: `TopbarComponent`, `SidebarComponent`
- **Data Components**: `DataTableComponent`, `TableComponent`, `FilterComponent`
- **Form Components**: `FormComponent`, `ModalComponent`, `DropdownComponent`
- **Feedback**: `FlashComponent`, `BreadcrumbComponent`
- **Interactive**: `ThemeToggleComponent`

### Internationalization
- **Supported Languages**: English (`en`), French (`fr`), Arabic (`ar`)
- **Locale Routing**: Automatic locale scope in routes
- **Translation Files**: Located in `config/locales/`
- **Management**: I18n tasks for translation management

### Filtering & Search
- **FilterableIndex**: Concern for index pages with filtering
- **FilterBuilder**: Service for constructing complex queries
- **Session Persistence**: Filters are stored in session with TTL
- **UI Integration**: FilterComponent for user controls

## 🔧 Development Commands

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

## 🎨 Customization

### Logo and Branding
- **Logo Location**: Replace `app/assets/images/logo.svg` with your application logo
- **Favicon**: Update `app/assets/images/favicon.ico`
- **Brand Colors**: Modify Tailwind CSS configuration in `tailwind.config.js`
- **Application Name**: Update in:
  - `config/application.rb`
  - `app/views/layouts/application.html.erb`
  - `package.json`

### Adding New Features
1. **Models**: Inherit from `ApplicationRecord`
2. **Controllers**: Include `Authentication` concern for protected actions
3. **Components**: Inherit from `BaseComponent` for consistent helper access
4. **Services**: Place complex business logic in `app/services/`
5. **Policies**: Add authorization policies in `app/policies/`

### Internationalization
1. **Add new languages**: Create locale files in `config/locales/`
2. **Update routing**: Add locale to `config/routes.rb`
3. **Extract translations**: Use `i18n:extract` rake task
4. **Update controllers**: Ensure all user-facing text uses `t()` helper

## 📦 Key Gems

- **Authentication**: Custom session-based authentication
- **Authorization**: `pundit` for policy-based authorization
- **UI Components**: `view_component` for component architecture
- **Frontend**: `turbo-rails`, `stimulus-rails` for Hotwire
- **Styling**: `tailwindcss-rails`, `daisyui-rails`
- **Search**: `ransack` for advanced search/filtering
- **Pagination**: `pagy` for efficient pagination
- **Auditing**: `audited` for model change tracking
- **Performance**: `goldiloader` for automatic eager loading
- **Security**: `hashid-rails` for obfuscated IDs
- **Enhancements**: `turbo_power` for enhanced Turbo Streams

## 🧪 Testing

The template includes a comprehensive testing setup:

- **RSpec**: Main testing framework
- **Factory Bot**: Test data generation
- **Database Cleaner**: Test isolation
- **Component Testing**: ViewComponent testing support
- **Shoulda Matchers**: Model validation testing
- **SimpleCov**: Code coverage reporting

## 🚀 Deployment

### Docker Support
The template includes Docker configuration:

```bash
# Build Docker image
docker build -t my-app .

# Run with Docker Compose
docker-compose up
```

### Production Considerations
- **Environment Variables**: Configure in production environment
- **Database**: Update `config/database.yml` for production
- **Assets**: Precompile assets with `./bin/rails assets:precompile`
- **Security**: Run `./bin/brakeman` in production environment

## 📚 Documentation

- **Development Guide**: See `CLAUDE.md` for detailed development instructions
- **API Documentation**: Generate with `./bin/rails apidoc` (if configured)
- **Component Documentation**: Each component includes inline documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This template is available under the MIT License. See LICENSE file for details.

## 🔗 Additional Resources

- [Rails Documentation](https://guides.rubyonrails.org/)
- [ViewComponent Documentation](https://viewcomponent.org/)
- [Tailwind CSS Documentation](https://tailwindcss.com/)
- [Hotwire Documentation](https://hotwired.dev/)
- [RSpec Documentation](https://rspec.info/)