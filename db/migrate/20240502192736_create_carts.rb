class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts do |t|
      t.decimal :total_price, precision: 17, scale: 2
      t.integer :status, default: 0, null: false
      t.datetime :last_interaction_at

      t.timestamps
    end

    add_index :carts, :status
  end
end
