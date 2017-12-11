# == Schema Information
#
# Table name: user_parameters
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  country_id              :integer
#  user_role_id            :integer
#  city                    :string(500)
#  summary                 :string(500)
#  keywords                :string(500)
#  ask_me                  :integer
#  experience              :text
#  current_position        :string(500)
#  interesting_markets     :string(500)
#  looking_for             :string(500)
#  startup_join            :integer          default(0)
#  startup_join_conditions :string(500)
#  startup_conditions      :string(500)
#  startup_add_value       :string(500)
#  startup_locations       :string(500)
#  website                 :string(500)
#  angellist               :string(500)
#  twitter                 :string(500)
#  linkedin                :string(500)
#  startups                :integer          default(0)
#  followers               :integer          default(0)
#  followings              :integer          default(0)
#  recommendations         :integer          default(0)
#  recommends              :integer          default(0)
#  connections             :integer          default(0)
#  score                   :integer
#  next_email              :datetime
#  last_email              :datetime
#  emails_sent             :integer          default(0)
#  intense                 :integer
#  referal_id              :integer
#  referal                 :string(20)
#  attend                  :integer          default(0)
#  fix                     :integer          default(0)
#  step                    :integer          default(1)
#  hash                    :string(510)
#  created                 :datetime
#

class User::Profile < ActiveRecord::Base

  # @TODO remove tweets_per_day

  self.table_name = "user_parameters"

  belongs_to :user
  belongs_to :country
  belongs_to :role, :class_name => 'User::Role', :foreign_key => 'user_role_id'

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :id, :user_id, :country_id, :user_role_id, :city, :summary, :skills, :ask_me, 
  # :experience, :current_position, :markets_interested_in, :looking_for, :startup_join, :startup_join_conditions, 
  # :startup_conditions, :startup_add_value, :startup_locations, :website, :angellist, :twitter, :linkedin,
  # :last_email_at, :emails_count, :referal_id, :referal_code, :fix, :step, :created_at

  attr_accessible :angellist, :ask_me, :attend, :city, :connections, 
  :country_id, :current_position, :emails_sent, :experience, :fix, 
  :followers, :followings, :intense, :markets_interested_in, :skills, 
  :last_email, :linkedin, :looking_for, :recommendations, 
  :recommends, :referal, :referal_id, :score, :startup_add_value, 
  :startup_conditions, :startup_join, :startup_join_conditions, 
  :startup_locations, :startups, :step, :summary, :twitter, :user_id, 
  :user_role_id, :website, :country_attributes

  accepts_nested_attributes_for :country

  before_create :default_values
  before_save :create_keywords_if_dont_exist

  def my_skills
    Keyword.skills.where(:url => skills)
  end

  def interesting_markets
    Keyword.markets.where(:url => markets_interested_in)
  end

  # Force disable_autotweet
  def disable_autotweet
    update_column(:tweets_per_day, 0) if persisted?
  end

  private

    def default_values
      self.step = 1
    end

    def create_keywords_if_dont_exist
      if self.valid?
        # Only one thing will be changing at a time. both fields are on differnet views.
        if skills_changed?
          exists = Keyword.where(:url => skills).pluck(:url)
          non_existant = skills - exists
          if non_existant.present?
            self.skills.delete_if { |e| non_existant.include? e }
            non_existant.each do |keyword|
              skill = Keyword.create(:title => keyword, :skill => true, :users_count => 1)
              self.skills << skill.url
            end
          end
        elsif markets_interested_in_changed?
          exists = Keyword.where(:url => markets_interested_in).pluck(:url)
          non_existant = markets_interested_in - exists
          if non_existant.present?
            self.markets_interested_in.delete_if { |e| non_existant.include? e }
            non_existant.each do |keyword|
              market = Keyword.create(:title => keyword, :market => true, :followers_count => 1)
              self.markets_interested_in << market.url
            end
          end
        end
      end
    end

end
