namespace :institutions_data do
  desc "Sync all the institutions data from GoCardless"
  task sync: :environment do
    puts "Syncing institutions data..."
    institutions = OpenBankingConnector.new.fetch_institutions_by_country("ES")

    institutions.each do |institution|
      temp_institution = Institution.find_by(institution_id: institution[:id])

      if temp_institution
        temp_institution.update!(
          name: institution[:name],
          thumbnail_url: institution[:logo]
        )
      else
        Institution.create!(
          institution_id: institution[:id],
          name: institution[:name],
          thumbnail_url: institution[:logo]
        )
      end
    end

    puts "Successfully synced #{institutions.count} institutions"
  end

end
