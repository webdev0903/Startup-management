namespace :keyword do

  task :import_from_keyword_tile_to_url => :environment do
    keywords = Keyword.all
    keywords.each do |keyword|
      if keyword.title.present?
        begin
          keyword.url = keyword.title.to_url
          if keyword.save
            Rails.logger.info "Successfully create the Keyword URL. Title - #{keyword.title}, URL - #{keyword.url}"
            puts("Successfully create the Keyword URL. Title - #{keyword.title}, URL - #{keyword.url}")
          else
            Rails.logger.info "Don't Create the Keyword URL. #{keyword.title}"
            puts("Don't Create the Keyword URL. #{keyword.title} ")
          end

        rescue => e
          Rails.logger.error "Error: Don't Create the Keyword URL. #{keyword.title}"
          puts("Error: Don't Create the Keyword URL. #{keyword.title}")
          Rails.logger.error e.message
          Rails.logger.debug e.backtrace.join("\n")
        end
      else
        puts("======================= NEXT Keyword ============================")
        next
      end
    end
  end
  
end