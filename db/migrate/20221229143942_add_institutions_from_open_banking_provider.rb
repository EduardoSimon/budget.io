class AddInstitutionsFromOpenBankingProvider < ActiveRecord::Migration[7.0]
  def up
    institutions = OpenBankingConnector.new.fetch_institutions_by_country("ES")

    institutions.each do |institution|
      Institution.create!(
        institution_id: institution[:id],
        name: institution[:name],
        thumbnail_url: institution[:logo]
      )
    end
  end

  def down
    Institution.destroy_all
  end
end
