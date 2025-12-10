class CreateRbacTables < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.text :description
      t.string :resource_type
      t.integer :resource_id

      t.timestamps
    end

    add_index :roles, [:name, :resource_type, :resource_id], unique: true
    add_index :roles, :name, unique: true, where: "resource_type IS NULL AND resource_id IS NULL"
    add_index :roles, [:resource_type, :resource_id]

    create_table :permissions do |t|
      t.string :name, null: false
      t.string :resource_type
      t.integer :resource_id
      t.text :description, null: false

      t.timestamps
    end

    add_index :permissions, [:name, :resource_type, :resource_id], unique: true
    add_index :permissions, [:resource_type, :resource_id]

    create_table :role_permissions do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true

      t.timestamps
    end

    add_index :role_permissions, [:role_id, :permission_id], unique: true

    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_roles, [:user_id, :role_id], unique: true

    create_table :users_roles, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
    end

    add_index :users_roles, [:user_id, :role_id], unique: true
    add_index :users_roles, [:role_id, :user_id]
  end
end
