puts "Cleaning database..."
CartItem.destroy_all
Cart.destroy_all
Product.destroy_all

# Create products with different stock levels and prices
products = [
  {
    name: 'Samsung Galaxy S24 Ultra',
    price: 12999.99
  },
  {
    name: 'iPhone 15 Pro Max',
    price: 14999.99
  },
  {
    name: 'Xiamo Mi 27 Pro Plus Master Ultra',
    price: 999.99
  },
  {
    name: 'Playstation 5',
    price: 4000.00
  },
  {
    name: 'Playstation 5 Pro',
    price: 7999.99
  },
  {
    name: 'NVIDIA RTX 5090',
    price: 25999.99
  }
]

created_products = Product.create!(products)

# Create carts in different states
puts "Creating carts in different states..."

# Active cart with items
active_cart = Cart.create!(
  status: :active,
  last_interaction_at: Time.current
)

# Add some products to active cart
CartItem.create!(
  cart: active_cart,
  product: created_products.first,
  quantity: 1
)
CartItem.create!(
  cart: active_cart,
  product: created_products.second,
  quantity: 2
)

# Abandoned cart (more than 3 hours old)
abandoned_cart = Cart.create!(
  status: :abandoned,
  last_interaction_at: 4.hours.ago
)
CartItem.create!(
  cart: abandoned_cart,
  product: created_products.third,
  quantity: 1
)

# Old abandoned cart (more than 7 days old)
old_abandoned_cart = Cart.create!(
  status: :abandoned,
  last_interaction_at: 8.days.ago
)
CartItem.create!(
  cart: old_abandoned_cart,
  product: created_products.last,
  quantity: 1
)

puts "Seed completed!"
puts "Created #{Product.count} products"
puts "Created #{Cart.count} carts"
puts "Created #{CartItem.count} cart items"

puts "\nTest data ready! You can now test the following scenarios:"
puts "\n1. Add items to cart:"
puts "POST /cart/add_item"
puts "payload: { cart_item: { product_id: #{created_products.first.id}, quantity: 1 } }"

puts "\n2. List cart items:"
puts "GET /cart"

puts "\n3. Remove item from cart:"
puts "DELETE /cart/#{created_products.first.id}"

puts "\nProduct IDs for testing:"
created_products.each do |product|
  puts "- #{product.name}: #{product.id}"
end
