class AddInstitutionIdToAuthSession < ActiveRecord::Migration[7.0]
  def change
    add_column :auth_sessions, :external_institution_id, :string
  end
end
