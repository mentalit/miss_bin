require 'csv'

class Article < ApplicationRecord
  belongs_to :store

  before_validation :pad_artno
  before_validation :pad_slid_h

  private

  def pad_artno
    self.artno = self.class.normalise_artno(artno)
  end

  def pad_slid_h
    self.slid_h = self.class.normalise_slid_h(slid_h)
  end

  public

  # Strips dots/spaces, pads to 8 digits with leading zeros.
  # "902.638.60" → "90263860"
  # "251135"     → "00251135"
  # "10257306"   → "10257306"
  def self.normalise_artno(value)
    return nil if value.nil?
    digits = value.to_s.gsub(/\D/, "")
    return nil if digits.empty?
    digits.rjust(8, "0")
  end

  # Pads slid_h to 6 characters with leading zeros.
  # "1234"   → "001234"
  # "12345"  → "012345"
  # "123456" → "123456"
  def self.normalise_slid_h(value)
    return nil if value.nil?
    return nil if value.to_s.strip.empty?
    value.to_s.strip.rjust(6, "0")
  end

  def self.import(file, store)
    CSV.foreach(file.path, headers: true) do |row|
      article_hash = {
        artno:     normalise_artno(row['Article Number']),
        artname:   row['Article Name'],
        price1:    row['Price1'],
        loc_price: row['Loc Price'],
        slid_h:    normalise_slid_h(row['Slid H']),
        SSD:       row['SSD'],
        EDS:       row['EDS']
      }

      store.articles.create!(article_hash)
    end
  end
end
