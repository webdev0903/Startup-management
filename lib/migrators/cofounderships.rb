require 'csv'

module Migrators
  module Cofounderships

    class << self

      BATCH_SIZE = 100
    
      def import!
        cofounderships = []
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/startup_cofounders.csv', :headers => true) do |row|
          row = row.to_hash
          cofounderships << Cofoundership.new(row)
          if cofounderships.size > BATCH_SIZE
            Cofoundership.import cofounderships, :validate => false
            cofounderships = []
          end
        end
        Cofoundership.import cofounderships, :validate => false
      end

    end

  end
end