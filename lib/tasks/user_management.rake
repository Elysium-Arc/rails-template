namespace :user do
  desc "Create a user or update password with confirmation"
  task create_or_update: :environment do
    require "io/console"

    print "Enter email_address: "
    email_address = STDIN.gets.strip

    user = User.find_by(email_address: email_address)
    if user
      puts "User exists. You can update the password."
    else
      puts "Creating new user."
      user = User.new(email_address: email_address)
    end

    # Password input with confirmation
    loop do
      print "Enter Password: "
      password = STDIN.noecho(&:gets).strip
      puts
      print "Confirm Password: "
      password_confirmation = STDIN.noecho(&:gets).strip
      puts

      if password != password_confirmation
        puts "Passwords do not match. Try again."
      elsif password.empty?
        puts "Password cannot be empty. Try again."
      else
        user.password = password
        break
      end
    end

    # Save user
    begin
      user.save!
      action = user.persisted? ? "updated" : "created"
      puts "User #{email_address} #{action} successfully."
    rescue ActiveRecord::RecordInvalid => e
      puts "Error: #{e.record.errors.full_messages.join(', ')}"
    end
  end
end
