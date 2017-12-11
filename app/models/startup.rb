# == Schema Information
#
# Table name: startups
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  group_id    :integer
#  title       :string(500)
#  summary     :string(280)
#  country_id  :integer
#  city        :string(500)
#  slug        :string(500)
#  keywords    :string(500)
#  about       :text
#  require     :string(500)
#  website     :string(500)
#  angellist   :string(500)
#  twitter     :string(500)
#  facebook    :string(500)
#  status      :integer          default(0)
#  english     :integer          default(1)
#  private     :integer          default(0)
#  homepage    :integer          default(0)
#  trending    :integer
#  followers   :integer
#  modified    :datetime
#  last_action :datetime
#  filename    :string(510)
#  created     :datetime
#

class Startup < ActiveRecord::Base
  include Photoable
  include PgSearch

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :id, :user_id, :group_id, :title, :summary, :country_id, :city, :url, :markets, 
  # :about, :require, :website, :angellist, :twitter, :facebook, :status, :english, :private, :homepage, 
  # :trending, :followers_count, :updated_at, :last_action_at, :lagacy_photo, :created_at

  # Fields 
  attr_accessible :photo, :user_id, :title, :summary, :country_id, :city, :url, :markets, :about,
    :require, :website, :angellist, :twitter, :facebook, :status, :english, :homepage, :trending,
    :followers_count, :last_action_at, :filename, :cofounders_count, :cofounder_attributes,
    :cofounder_ids, :last_email_at
  # Url
  acts_as_url :title, :limit => 50, :sync_url => true

  # Relations
  has_many :followerships, :dependent => :destroy
  has_many :followers, :through => :followerships, :source => :following
  has_one :statistic, :class_name => 'Startup::Statistic', :dependent => :destroy

  has_many :cofounderships, :dependent => :destroy
  has_many :cofounders, :through => :cofounderships, :source => :user
  has_many :notifications, :dependent => :destroy
  has_many :posts, -> { order('created_at DESC') }

  belongs_to :country
  belongs_to :owner, foreign_key: :user_id, class_name: User

  scope :active, -> { where(status: true) }
  scope :inactive, -> { where("status != 't'") }
  
  validate :status_of_user_must_active

  has_attached_file :photo,
    :path => ':rails_root/public/uploads/:class/:attachment/:id/:style/:filename',
    :url => '/uploads/:class/:attachment/:id/:style/:filename',
    :styles => {
      :small => {
        :geometry => "40x40#",
        :quality => "93"
      },
      :thumb => {
        :geometry => "120x120#",
        :quality => "93"
      },
      :middle => {
        :geometry => "300x300>",
        :quality => "93"
      },
      :big => {
        :geometry => "500x500>",
        :quality => "93"
      },
      :large => {
        :geometry => "800x800>",
        :quality => "93"
      }
    },
    :default_url => '/startup.png'

  accepts_nested_attributes_for :cofounders
  
  # Validation
  validates :title, :summary, :country_id, presence: true
  validates :markets, :length => { :minimum => 1 } 
  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => /^image\/(jpg|jpeg|pjpeg|png|x-png|gif)$/, :message => 'file type is not allowed (only jpeg/png/gif images)'

  default_scope { where(status: true) }

  #search scopes
  pg_search_scope :search_by_city, :against => :city
  pg_search_scope :search_by_title_about, :against => [:title, :about, :summary]

  before_save :create_keywords_if_dont_exist

  def my_markets
    Keyword.markets.where(:url => markets)
  end

  def to_param
    url
  end

  def founder?(user)
    return false unless user
    user_id == user.id || cofounders.pluck(:id).include?(user.id)
  end

  def founders    
    return cofounders unless owner
    (cofounders + [owner]).uniq
  end

  def web
    return Rails.application.routes.url_helpers.startup_path(self) unless website
    website
  end

  private

    def create_keywords_if_dont_exist
      if self.valid?
        exists = Keyword.where(:url => self.markets).pluck(:url)
        non_existant = markets - exists
        if non_existant.present?
          self.markets.delete_if { |e| non_existant.include? e }
          non_existant.map do |keyword|
            market = Keyword.create(:title => keyword, :market => true, :followers_count => 1)
            self.markets << market.url
          end
        end
      end
    end

    def status_of_user_must_active
      errors.add(:owner, I18n.t('.errors.messages.user_is_not_active')) if owner && !owner.status?
    end
end
