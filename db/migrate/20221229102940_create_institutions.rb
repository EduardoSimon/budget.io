class CreateInstitutions < ActiveRecord::Migration[7.0]
  def change
    create_table :institutions do |t|
      t.string :name
      t.string :institution_id, index: {unique: true, name: "unique_institution_id"}
      t.string :thumbnail_url

      t.timestamps
    end
  end
end
