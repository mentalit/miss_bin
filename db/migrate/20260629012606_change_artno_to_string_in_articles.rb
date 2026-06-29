class ChangeArtnoToStringInArticles < ActiveRecord::Migration[7.1]
    def up
    # Convert existing integer values to zero-padded 8-char strings
    change_column :articles, :artno, :string
 
    Article.find_each do |a|
      a.update_column(:artno, a.artno.to_s.rjust(8, "0")) if a.artno.present?
    end
  end
 
  def down
    change_column :articles, :artno, :integer
  end

end
