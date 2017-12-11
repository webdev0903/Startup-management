# == Schema Information
#
# Table name: groups
#
#  id           :integer          not null, primary key
#  title        :string(60)       not null
#  slug         :string(500)
#  about        :string(510)      not null
#  long_about   :text
#  user_id      :integer          not null
#  privacy      :integer          not null
#  member_count :integer          default(1), not null
#  status       :integer          default(1)
#  homepage     :integer
#  trending     :integer
#  created      :datetime         not null
#  last_action  :datetime
#  filename     :string(510)
#

class Group < ActiveRecord::Base
  include Photoable
  include PgSearch

  # NOTE: Use this while importing form lagacy DB
  # attr_accessible :id, :title, :url, :about, :long_about, :user_id, :privacy, :members_count,
  #   :status, :homepage, :trending, :created_at, :last_action_at, :lagacy_photo
  attr_accessible :title, :about, :long_about, :photo

  # NOTE: Coment this line when importing lagacy DB
  acts_as_url :title, :limit => 50, :sync_url => true

  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  validates :owner, presence: true
  validate :status_of_user_must_active

  has_many :posts, :dependent => :destroy

  has_many :memberships, -> { where :status => true }, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :user

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
    :default_url => '/group.png'

  validates :title, :about, :long_about, :presence => true
  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => /^image\/(jpg|jpeg|pjpeg|png|x-png|gif)$/, :message => 'file type is not allowed (only jpeg/png/gif images)'

  scope :active, -> { where(status: true) }

  #search scopes
  pg_search_scope :search_by_title_about, :against => [:title, :about, :long_about]


  before_create :default_values
  after_create :create_memberhip_of_owner

  def to_param
    url
  end

  private

    def default_values
      self.privacy = 0
      self.last_action_at = Time.now
      self.members_count = 0
    end

    def create_memberhip_of_owner
      self.members << owner
    end

    def status_of_user_must_active
    errors.add(:owner, I18n.t('.errors.messages.user_is_not_active')) if owner && !owner.status?

    end
end
