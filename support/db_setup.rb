require "sqlite3"
require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :properties, force: true do |t|
    t.string :address
    t.string :postcode
    t.string :type
    t.timestamps
  end
  
  add_index :properties, [:address, :postcode, :type], unique: true, name: "properties_multiples"

  create_table :transactions, force: true do |t|
    t.string :type
    t.references :agency
    t.references :client
    t.references :property
    t.datetime :date
    t.timestamps
  end

  add_index :transactions, [:type, :agency, :client, :property, :date], unique: true, name: "ref"

  create_table :clients, force: true do |t|
    t.string :name
    t.timestamps
  end

  create_table :imports, force: true do |t|
    t.string :name, unique: true
    t.timestamps
  end

  create_table :agencies, force: true do |t|
    t.string :name
    t.string :import_id, unique: true
    t.timestamps
  end

  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    self.inheritance_column = :_type_disabled
  end

  class Property < ApplicationRecord
    has_many :transactions
    validates :address, uniqueness: { scope: [:postcode, :type]}
  end

  class Transaction < ApplicationRecord
    belongs_to :property
    belongs_to :client
    belongs_to :agency
  end

  class Client < ApplicationRecord
    has_many :transactions
  end

  class Import < ApplicationRecord
    validates :name, uniqueness: { message: "You are trying to run the same import a second time" }
  end

  class Agency < ApplicationRecord
    has_many :transactions
  end
end
