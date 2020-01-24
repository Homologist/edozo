require 'csv'
class CsvImport
  def initialize(filename, agency_name)
    @filename = filename
    @agency_name = agency_name
  end

  def run
    records = CSV.foreach(@filename, headers: true)
    headers = CSV.read(@filename)[0]
    raise(ImportFile::FormatError.new("File format is incorrect")) if headers.to_a.count != 6
    return if records.to_a.empty?
    import_id = Digest::SHA256.hexdigest records.to_a.to_s
    Import.create! name: import_id

    records.each do |record|
      if record.map{ |line| line.second }.compact.count != 6
        CSV.open("./corrections/error.csv", "a+") do |csv|
          csv << record
        end
        next
      end

      ActiveRecord::Base.transaction do
        client = Client.create! name: record[5]
        agency = Agency.create! name: agency_name
        property = Property.create address: record[0], postcode: record[1], type: record[2]
        Transaction.create type: record[3], date: record[4], client: client, agency: agency, property: property
        rescue ActiveRecord::RecordNotUnique
          raise ActiveRecord::Rollback
      end
    end

    rescue Errno::ENOENT
      raise ImportFile::LocationError
  end

  def filename
    @filename
  end

  def agency_name
    @agency_name
  end
end

class ImportFile < StandardError
end

class ImportFile::LocationError < StandardError
  def message
    "File is missing"
  end
end

class ImportFile::FormatError < StandardError
end
