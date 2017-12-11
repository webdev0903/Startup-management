class ImageMigrators

  class << self

    def start
      model_with_image.each do |m|
        definition = Paperclip::AttachmentRegistry.instance.definitions_for(m).keys.first
        m.all.each do |mi|
          if mi.lagacy_photo && mi.photo.blank?
            begin
              remote_photo = open('http://starterpad.com/photos/' + mi.lagacy_photo)
              def remote_photo.original_filename;base_uri.path.split('/').last; end
            rescue 
              remote_photo = open(Rails.root.join 'public', m.to_s.downcase + '.png')
            end

            mi.send(definition.to_s + '=', remote_photo)
            mi.save(:validate => false)
            remote_photo.close
          end
        end
      end
    end

    def model_with_image
      [Group, Startup, User]
    end

  end
end