require 'csv'

module Migrators
  module Keywords

    class << self

      # NOTE: Keywords are to be imported before User Profiles
      
      def import!
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/keywords.csv', :headers => true) do |row|
          row = row.to_hash
          row.delete 'id'
          keyword = Keyword.new(row)
          keyword.save
        end
      end

    end

  end
end