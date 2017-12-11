# == Schema Information
#
# Table name: user_twitters
#
#  id              :integer
#  user_id         :integer
#  screen_name     :string(500)
#  tweets          :integer
#  tweets_per_day  :integer
#  next_send       :datetime
#  twitter_user_id :integer
#  revoked         :integer          default(0)
#  bad             :integer          default(0)
#  hash            :string(500)
#  secret          :string(500)
#  key             :string(500)
#

class User::TwitterAuth < ActiveRecord::Base
  attr_accessible :next_send_at
  self.table_name = "user_twitters"
  self.primary_key = :id 

  belongs_to :user
  
  # validation
  validates :tweets_per_day, inclusion: { in: [0, 1, 2, 3] },
                              numericality: true, allow_blank: true
  validate  :autotweet_validation

  def update_next_send
    update_attributes(next_send_at: Time.zone.now + (1.day / tweets_per_day)) if tweets_per_day && tweets_per_day > 0 
  end

  private

    # Validation method, it force disable autotweet if invalid
    def autotweet_validation
      user.twitter_service.blank?
      if tweets_per_day_changed? && user.twitter_service.blank?
        errors.add(:tweets_per_day, 'cant be set, you have revoked our apps from your twitter or you havent connect your twitter, please try again later') 
        disable_autotweet
        return false
      end
      true
    end
    def disable_autotweet
      update_column(:tweets_per_day, 0) if persisted?
    end

end
