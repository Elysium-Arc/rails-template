#!/usr/bin/env ruby

# generate_from_template.rb
#
# This script replaces all instances of "ElysiumArc" in the Rails application
# with a provided app name. It's used to customize this template for a new project.
#
# Usage: ruby generate_from_template.rb <new_app_name>
# Example: ruby generate_from_template.rb "MyAwesomeApp"

require 'fileutils'
require 'optparse'

class TemplateGenerator
  attr_reader :new_app_name, :files_to_modify

  def initialize(new_app_name)
    @new_app_name = new_app_name
    @files_to_modify = [
      'README.md',
      'CLAUDE.md',
      'Dockerfile',
      'config/locales/fr.yml',
      'config/locales/en.yml',
      'config/locales/ar.yml',
      'config/cable.yml',
      'config/application.rb',
      'app/views/layouts/_head.html.erb',
      'app/views/pwa/manifest.json.erb',
      'app/components/sidebar_component.html.erb'
    ]
  end

  def run
    validate_app_name
    print_summary
    confirm_proceed

    puts "\n🔄 Replacing ElysiumArc with #{new_app_name}..."

    files_modified = 0

    files_to_modify.each do |file_path|
      if File.exist?(file_path)
        if modify_file(file_path)
          files_modified += 1
          puts "  ✅ Updated: #{file_path}"
        else
          puts "  ⚠️  No changes needed: #{file_path}"
        end
      else
        puts "  ❌ File not found: #{file_path}"
      end
    end

    puts "\n✨ Template generation complete!"
    puts "📁 Modified #{files_modified} files"
    puts "🚀 Your Rails app '#{new_app_name}' is ready to use!"

    show_next_steps
  end

  private

  def validate_app_name
    if new_app_name.nil? || new_app_name.strip.empty?
      puts "❌ Error: App name is required"
      puts "Usage: ruby #{__FILE__} <app_name>"
      exit 1
    end

    if new_app_name !~ /^[a-zA-Z][a-zA-Z0-9_]*$/
      puts "❌ Error: App name must start with a letter and contain only letters, numbers, and underscores"
      exit 1
    end

    if new_app_name.length < 2
      puts "❌ Error: App name must be at least 2 characters long"
      exit 1
    end
  end

  def print_summary
    puts "\n📋 Template Generation Summary"
    puts "=" * 40
    puts "Current app name: ElysiumArc"
    puts "New app name: #{new_app_name}"
    puts "Files to modify: #{files_to_modify.length}"
    puts "\nFiles that will be updated:"
    files_to_modify.each { |file| puts "  - #{file}" }
  end

  def confirm_proceed
    print "\n⚠️  This will modify the files listed above. Proceed? (y/N): "
    response = $stdin.gets&.chomp&.downcase

    unless %w[y yes].include?(response)
      puts "❌ Operation cancelled by user"
      exit 0
    end
  end

  def modify_file(file_path)
    content = File.read(file_path)
    modified_content = content.gsub('ElysiumArc', new_app_name)

    # Only write if content actually changed
    if content != modified_content
      File.write(file_path, modified_content)
      true
    else
      false
    end
  end

  def show_next_steps
    puts "\n🎯 Next Steps:"
    puts "1. Review the changes with: git diff"
    puts "2. Commit the changes: git add . && git commit -m 'Customize template for #{new_app_name}'"
    puts "3. Update your README.md with project-specific information"
    puts "4. Run './bin/rails db:create db:migrate' to set up the database"
    puts "5. Start the development server with './bin/rails server'"
    puts "\n💡 Don't forget to:"
    puts "   - Update the description in package.json"
    puts "   - Customize the logo (public/logo.svg)"
    puts "   - Set up your environment variables"
  end
end

# Parse command line arguments
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby #{__FILE__} [options] <app_name>"

  opts.on("-y", "--yes", "Skip confirmation prompt") do
    options[:auto_confirm] = true
  end

  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit 0
  end
end.parse!

# Get the app name from positional arguments
app_name = ARGV[0]

if app_name.nil? || app_name.empty?
  puts "❌ Error: App name is required"
  puts "Usage: ruby #{__FILE__} <app_name>"
  puts "       ruby #{__FILE__} --help for more options"
  exit 1
end

# Create and run the generator
generator = TemplateGenerator.new(app_name)

# Override confirmation method if auto-confirm is set
if options[:auto_confirm]
  def generator.confirm_proceed
    puts "\n⚡ Auto-confirm mode: Proceeding with file modifications..."
  end
end

generator.run