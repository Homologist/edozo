require 'rspec'
require_relative '../../lib/search_service'
require_relative '../../lib/csv_import'

RSpec.describe SearchService do
  let(:agency_name) { "Some Agent" }
  let(:filename) { "spec/fixtures/seed.csv" }
  let!(:import) { CsvImport.new(filename, agency_name) }

  describe "finding by postcode" do

    it "returns all transactions for postcode" do
      import.run

      expect(SearchService.transaction_by_postcode("DT2 9DF").count).to eq(1)
    end
  end

  describe "finding by property type" do
    it  "returns all office properties" do
      import.run

      expect(SearchService.all_office.count).to eq(2)
    end

    it  "returns all rental properties" do
      import.run

      expect(SearchService.all_rental.count).to eq(2)
    end
  end

  describe "finding by transaction type" do
    it  "returns all sale transactions when sale type provided" do
      import.run

      expect(SearchService.transactions_by_sale.count).to eq(1)
    end

    it  "returns all rent transactions when rent type provided" do
      import.run

      expect(SearchService.transactions_by_rent.count).to eq(3)
    end
  end

  describe "finding nearby" do
    # NOTE: we can consider properties of the same outcode (first part of postcode) as nearby
    it "returns all transaction nearby of the provided property" do
      import.run

      expect(SearchService.transactions_nearby("DT2").count).to eq(3)
    end
  end
  
  describe "finding within dates" do
    it "returns all transaction that happened between start and end date" do
      import.run

      expect(SearchService.transactions_within_dates("2015-09-09", "2017-10-10").count).to eq(1)
    end
  end

  describe "finding by agency name" do
    it "returns all transactions by agency name" do
      import.run

      expect(SearchService.transactions_by_agency_name("Some Agent").count).to eq(4)
    end
  end

  describe "finding by client name" do
    it "returns all transactions by client name" do
      import.run

      expect(SearchService.transactions_by_client_name("ASOS").count).to eq(2)
    end
  end

  describe "finding by postcode within date" do
    it "returns all transactions for postcode between start and end date" do
      import.run

      expect(SearchService.all_by_postcode_within_dates("DT2 9DE", "2018-01-01", "2020-01-01").count).to eq(2)
    end
  end

  describe "finding by property and transaction type, within postcode and dates, by agent name and client name" do
    it "returns all transactions for given parameters" do
      import.run
    
      expect(SearchService.all_by_property_type_transaction_type_postcode_within_dates_agent_name_client_name("office", "sale", "DT2 9DF", "2018-01-01", "2020-01-01", "Some Agent", "RightSpace").count).to eq(1)
    end

  end

  describe "find transaction history for property" do
    it "returns all transactions for given property id" do
      import.run
      
      expect(SearchService.transactions_by_properties(2).count).to eq(1)
    end
  end
end
