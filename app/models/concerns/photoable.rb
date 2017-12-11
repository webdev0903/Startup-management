module Photoable
  extend ActiveSupport::Concern

  included do
    def _photo(style)
      url = photo.send :url, style
      url = case style
      when :small
        # For now...
        '/photos/40.' + lagacy_photo
      when :thumb
        '/photos/122.' + lagacy_photo
      when :middle
        '/photos/300.' + lagacy_photo
      when :big
        '/photos/500.' + lagacy_photo
      end if photo.blank? && lagacy_photo.present?
      url
    end
  end
  
end