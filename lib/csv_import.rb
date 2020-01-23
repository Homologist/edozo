require 'csv'
class CsvImport
  def initialize(filename, agency_name)
    @filename = filename
    @agency_name = agency_name
  end

  def run
    records  = CSV.foreach(@filename, headers: true)
      puts records.to_a
      puts "records"
    records.each do |record|
      next if record.uniq.reject(&:empty?).compact.empty?
      ActiveRecord::Base.transaction do
        client = Client.create! name: record[5]
        agency = Agency.create! name: agency_name
        property = Property.create! address: record[0], postcode: record[1], type: record[2]
        Transaction.create type: record[3], date: record[4], client: client, agency: agency, property: property
        rescue ActiveRecord::RecordNotUnique
      end

    end
  end

  def filename
    @filename
  end

  def agency_name
    @agency_name
  end
end
