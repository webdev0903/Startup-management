# == Schema Information
#
# Table name: keywords
#
#  id        :integer          not null, primary key
#  parent_id :integer
#  title     :string(500)
#  skill     :integer          default(0)
#  market    :integer          default(0)
#  users     :integer
#  startups  :integer
#  followers :integer
#  status    :integer
#  sync_date :datetime
#  modified  :datetime
#

class Keyword < ActiveRecord::Base

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :title, :url, :skill, :market, :parent_id,
  # :users_count, :followers_count, :startups_count, :status, :synced_at, :created_at

  attr_accessible :title, :url, :skill, :market, 
  :users_count, :followers_count, :startups_count

  scope :skills, -> { where(:skill => true) }
  scope :markets, -> { where(:market => true) }

  # Make Slug
  acts_as_url :title, :limit => 50, :sync_url => true

  # before_create :set_init_values

  def users
    column = skill? ? 'skills' : 'markets_interested_in'
    User.joins(:profile).where("? = ANY(user_parameters.#{column})", url)
  end

  def startups
    Startup.where("? = ANY(markets)", url)
  end

  # private

  #   def set_init_values
  #     self.startups_count = 0
  #   end

end
