json.extract! article, :id, :artno, :artname, :price1, :loc_price, :slid_h, :SSD, :EDS, :store_id, :created_at, :updated_at
json.url article_url(article, format: :json)
