class CreateContributions < ActiveRecord::Migration[6.1]
  def change
    create_table :contributions do |t|
      t.string :bike_type
      t.string :model_year
      t.string :bike_img
      t.string :my_favo
      t.integer :good, :default => 0
      t.string :custom_part
      t.string :custom_brand
      t.string :custom_url
      t.timestamps null: false
    end
  end
end
