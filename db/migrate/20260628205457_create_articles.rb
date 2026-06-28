class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.integer :artno
      t.string :artname
      t.float :price1
      t.float :loc_price
      t.string :slid_h
      t.date :SSD
      t.date :EDS
      t.references :store, null: false, foreign_key: true

      t.timestamps
    end
  end
end
