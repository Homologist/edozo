require 'rspec'
require_relative '../../lib/csv_import'

RSpec.describe CsvImport do
  let(:agency_name) { "Some Agent" }
  let!(:import) { described_class.new(filename, agency_name) }

  describe "initializing" do
    let(:filename) { "spec/fixtures/empty.csv" }

    it "sets filename and agency name attribute" do
      expect(import.filename).to eq(filename)
      expect(import.agency_name).to eq(agency_name)
    end
  end

  describe "file with a single record" do
    let(:filename) { "spec/fixtures/single.csv" }

    it "creates one transaction with property, client and agency" do
      import.run

      transaction = Transaction.last

      expect(transaction).to_not be_nil
      expect(transaction.property).to_not be_nil
      expect(transaction.client).to_not be_nil
      expect(transaction.agency.name).to eq agency_name
    end
  end

  describe "file with a duplicate record" do
    let(:filename) { "spec/fixtures/duplicate.csv" }

    it "creates only one transaction, property, client and agency" do
      import.run
      expect(Property.count).to eq 1
      expect(Client.count).to eq 1
      expect(Agency.count).to eq 1
      expect(Transaction.count).to eq 1
    end
  end

  describe "import including multiple transactions" do
    let(:filename) { "spec/fixtures/multiple.csv" }

    it "creates only one property with multiple transactions" do
      import.run

      expect(Property.count).to eq 1
      expect(Transaction.count).to eq 2
    end
  end

  describe "when running the same import multiple times" do
    let(:filename) { "spec/fixtures/single.csv" }

    it "creates no transactions and returns meaningful message" do
      import.run

      expect { import.run }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name You are trying to run the same import a second time")
    end
  end

  describe "missing file" do
    let(:filename) { "spec/fixtures/missing.csv" }

    it "raises an exception with meaningful message" do
      expect { import.run }.to raise_error(ImportFile::LocationError, "File is missing")
    end
  end

  describe "empty file" do
    let(:filename) { "spec/fixtures/empty.csv" }

    it "creates no transactions with empty import" do
      import.run

      expect(Property.count).to eq 0
    end
  end

  describe "incorrectly formatted file" do
    let(:filename) { "spec/fixtures/incorrect.csv" }

    it "raises an exception with a meaningful message" do
      expect { import.run }.to raise_error(ImportFile::FormatError, "File format is incorrect")
    end
  end

  describe "file with some invalid records" do
    let(:filename) { "spec/fixtures/some_invalid_records.csv" }

    it "imports correct records and saves remaining records into corrections directory" do
      import.run

      expect(Transaction.count).to eq 1
      expect(Property.count).to eq 1
      expect(Client.count).to eq 1
      expect(Agency.count).to eq 1
      expect(CSV.read("./corrections/error.csv").count).to eq(2)

      File.delete "./corrections/error.csv"
    end
  end
end
