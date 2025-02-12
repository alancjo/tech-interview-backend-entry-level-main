class AddAbandonedFieldsToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :abandoned, :boolean
    add_column :carts, :abandoned_at, :datetime

    add_index :carts, :abandoned
  end
end
