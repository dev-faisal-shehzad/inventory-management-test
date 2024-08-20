namespace :update_db do
  desc "Update on_shelf column for products using the view"
  task update_on_shelf: :environment do
    Product.reset_column_information

    quantities = Product.connection.select_all('SELECT product_id, quantity FROM product_on_shelf_quantities')

    quantities.each do |row|
      product = Product.find_by_id(row['product_id'])
      product.update(on_shelf: row['quantity']) if product.present?
    end
  end
end
