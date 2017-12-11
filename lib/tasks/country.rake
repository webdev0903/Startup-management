require 'fuzzy_match'

namespace :country do
  task :migrate_country_tile_to_url_slug => :environment do
    countries = Country.all
    countries.each do |country|
      begin
        country.url_slug = country.title.to_url
        if country.save
          Rails.logger.info "Successfully create the Country URL slug. Title - #{country.title}, Slug - #{country.url_slug}"
          puts("Successfully create the Country URL slug. Title - #{country.title}, Slug - #{country.url_slug}")
        else
          Rails.logger.info "Don't Create the URL Slug. #{country.title} "
          puts("Don't Create the URL Slug. #{country.title} ")

        end

      rescue => e
        Rails.logger.error "Error: Don't Create the URL Slug. #{country.title} "
        puts("Error: Don't Create the URL Slug. #{country.title} ")
        Rails.logger.error e.message
        Rails.logger.debug e.backtrace.join("\n")
      end
    end
  end


  #copied all city to city_old
  task :fix_city_name, [:limit, :skip] => :environment do |t, args|
    args.with_defaults(:limit => 10, :skip =>  0)
    profiles = User::Profile.where('city_old is not ?', nil).limit(args[:limit]).offset(args[:skip])
    profiles.each do |profile|
      if profile.city_old.present? && profile.country.present?
        begin
          city_name = profile.city_old.downcase
          country_name = profile.country.title.downcase
          base_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{city_name},#{country_name}&key=AIzaSyAileuwWKD_owghf3gQyyM4ATAJHvK-c70"
          resp = Net::HTTP.get_response(URI.parse(URI.encode(base_url)))
          data = resp.body
          result = JSON.parse(data)
          if result["status"] == "OVER_QUERY_LIMIT"
            puts result["status"]
            break
          end
          sleep 0.25
          cities = []
          result["results"].each do |res|
            country = ''
            city = ''
            res["address_components"].each do |component|
              country = component["long_name"] if component["types"].include? 'country'
            end

            res["address_components"].each do |component|
              cities.concat([component["long_name"], component["short_name"]] )  if ((component["types"] & ['locality','route', 'neighborhood', 'administrative_area_level_2', 'sublocality_level_1']).any? && country.downcase == country_name)
            end
          end 
          cities.uniq!
          #puts cities.inspect
          match = FuzzyMatch.new(cities).find(profile.city_old) if cities.length
          profile.city = match ? match : profile.city_old

          if profile.save
            Rails.logger.info "Successfully Save the clean City. City - #{profile.city} from #{profile.city_old}, #{profile.country.title} "
            puts("Successfully Save the clean City. City - #{profile.city} from #{profile.city_old}, #{profile.country.title} ")
          else
            Rails.logger.info "Don't Save the clean City. City - #{profile.city_old}, #{profile.country.title}"
            puts("Don't Save the clean City. City - #{profile.city_old}, #{profile.country.title}")
          end
          rescue => e
            Rails.logger.error "Error: Don't Save the clean City. City - #{profile.id}"
            puts("Error: Don't Save the clean City. City - #{profile.id}")
            puts(e.message)
            Rails.logger.error e.message
            Rails.logger.debug e.backtrace.join("\n")
        end
      else
        puts("======================= NEXT ============================")
        next
      end
    end
  end

  task :clean_city_name => :environment do
    profiles = User::Profile.all
    profiles.each do |profile|
      if profile.city.present?
        begin
          if profile.city =~ /\,/ # City with ',' content.
            city_array = profile.city.split(",") 
          elsif profile.city =~ /\// # City with '/' content.
            city_array = profile.city.split("/")
          elsif profile.city =~ /\-/ # City with '-' content.
            city_array = profile.city.split("-")
          else
            city_array = profile.city.split(",") # Pass this is as a default city array
          end
          profile.city = city_array[0].strip
          profile.city = profile.city.split.map(&:capitalize)*' ' # Make more than one word city into Capitalize
          if profile.save
            Rails.logger.info "Successfully Save the clean City. City - #{profile.city}"
            puts("Successfully Save the clean City. City - #{profile.city}")
          else
            Rails.logger.info "Don't Save the clean City. City - #{profile.city}"
            puts("Don't Save the clean City. City - #{profile.city}")
          end

        rescue => e
          Rails.logger.error "Error: Don't Save the clean City. City - #{profile.id}"
          puts("Error: Don't Save the clean City. City - #{profile.id}")
          Rails.logger.error e.message
          Rails.logger.debug e.backtrace.join("\n")
        end
      else
        puts("======================= NEXT ============================")
        next
      end
    end
  end
end
