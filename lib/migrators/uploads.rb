require 'csv'

module Migrators
  module Uploads

    class << self

      def import!
        csv = CSV.foreach(Rails.root.to_s + '/db/lagacy/uploads.csv', :headers => true) do |row|
          row = row.to_hash
          foreign_key = row['model'].downcase + '_id'
          object = row['model'].constantize.where(:id => row[foreign_key]).first
          object.update_column(:lagacy_photo, row['filename']) if object.present?
        end
      end

    end

  end
end