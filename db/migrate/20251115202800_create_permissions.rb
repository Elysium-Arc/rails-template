class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions do |t|
      t.string :name, null: false
      t.string :resource_type
      t.integer :resource_id
      t.text :description

      t.timestamps
    end

    add_index :permissions, [:name, :resource_type, :resource_id], unique: true, name: "index_permissions_on_name_and_resource"
    add_index :permissions, [:resource_type, :resource_id]
  end
end
