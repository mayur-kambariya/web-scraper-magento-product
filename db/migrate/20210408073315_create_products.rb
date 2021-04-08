class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :price
      t.text :detail
      t.text :extra_info

      t.timestamps
    end
  end
end
