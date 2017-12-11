require 'csv'

module Migrators
  module Countries

    class << self

      BATCH_SIZE = 100
    
      def import!
        countries = []
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/countries.csv', :headers => true) do |row|
          row = row.to_hash
          row.delete 'status'
          countries << Country.new(row)
          if countries.size > BATCH_SIZE
            Country.import countries, :validate => false
            countries = []
          end
        end
        Country.import countries, :validate => false
      end

    end

  end
end