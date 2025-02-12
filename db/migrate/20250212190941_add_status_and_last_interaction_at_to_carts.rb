class AddStatusAndLastInteractionAtToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :integer, default: 0, null: false
    add_column :carts, :last_interaction_at, :datetime
    add_index :carts, :status
  end
end
