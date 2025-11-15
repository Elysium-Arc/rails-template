class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.text :description
      t.string :resource_type
      t.integer :resource_id

      t.timestamps
    end

    add_index :roles, :name, unique: true
    add_index :roles, [:name, :resource_type, :resource_id], unique: true, name: "index_roles_on_name_and_resource"
    add_index :roles, [:resource_type, :resource_id]
  end
end
