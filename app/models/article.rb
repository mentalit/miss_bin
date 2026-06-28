require 'csv'

class Article < ApplicationRecord
  belongs_to :store

  # 1. Accept the 'store' object passed from your controller
  def self.import(file, store)
    CSV.foreach(file.path, headers: true) do |row|
      
      # 2. Build your custom hash exactly like you had it
      article_hash = {
        artno:     row['Article Number'],
        artname:   row['Article Name'],
        price1:    row['Price1'],
        loc_price: row['Loc Price'],
        slid_h:    row['Slid H'],
        SSD:       row['SSD'], 
        EDS:       row['EDS']
      }
      
      # 3. Use the store relationship block to automatically inject the store_id
      store.articles.create!(article_hash)
    end
  end
end

