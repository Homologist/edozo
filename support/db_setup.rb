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

  create_table :agencies, force: true do |t|
    t.string :name
    t.timestamps
  end

  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    self.inheritance_column = :_type_disabled
  end

  class Property < ApplicationRecord
    has_many :transactions
  end

  class Transaction < ApplicationRecord
    belongs_to :property
    belongs_to :client
    belongs_to :agency
  end

  class Client < ApplicationRecord
    has_many :transactions
  end

  class Agency < ApplicationRecord
    has_many :transactions
  end
end
