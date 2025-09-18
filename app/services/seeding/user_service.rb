class Seeding::UserService
  def self.create_user(email_address, password)
    user = User.find_or_initialize_by(email_address: email_address)

    if user.new_record?
      user.password = password
      user.password_confirmation = password
      user.save!
      puts "Created user with email address #{email_address}"
    else
      puts "User with email address #{email_address} already exists"
    end

    user
  end
end
