class SearchService

  def self.transaction_by_postcode(postcode)
    Transaction.joins(:property).where(properties: {postcode: postcode})
  end

  def self.all_rental
    Property.where(type: "rental")
  end

  def self.all_office
    Property.where(type: "office")
  end

  def self.transactions_by_sale
    Transaction.where(type: "sale")
  end

  def self.transactions_by_rent
    Transaction.where(type: "lease")
  end

  def self.transactions_nearby(postcode)
    Transaction.joins(:property).where("properties.postcode LIKE '%#{postcode.split(' ').first}%'")
  end

  def self.transactions_within_dates(date1, date2)
    Transaction.where("transactions.date > date('#{date1}') AND transactions.date <= date('#{date2}')")
  end

  def self.transactions_by_agency_name(name)
    Transaction.joins(:agency).where(agencies: { name: name }) 
  end 

  def self.transactions_by_client_name(name) 
    Transaction.joins(:client).where(clients: { name: name })
  end

  def self.all_by_postcode_within_dates(postcode, date1, date2)
    Transaction.joins(:property).where("transactions.date > date('#{date1}') AND transactions.date <= date('#{date2}')").where(properties: {postcode: postcode})
  end

  def self.all_by_property_type_transaction_type_postcode_within_dates_agent_name_client_name(type1, type2, postcode, date1, date2, name1, name2)
    all_by_postcode_within_dates(postcode, date1, date2).joins(:agency).joins(:client).joins(:property).where(agencies: {name: name1}).where(clients: {name: name2}).where(properties: {type: type1}).where(transactions: {type: type2})
  end

  def self.transactions_by_properties(id)
    Transaction.joins(:property).where(property_id: id)
  end
end

