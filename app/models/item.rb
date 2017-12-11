class Item < ActiveRecord::Base
  attr_accessible :title, :content, :url, :downvotes_count, :upvotes_count, :score, :rank

  acts_as_url :title, :url_attribute => :uri, :limit => 50, :sync_url => true

  belongs_to :user
  has_many :votes, as: :votable
  has_many :comments, class_name: "ItemComment"

  validates :title, presence: true, length: { maximum: 250 }, allow_blank: false, allow_nil: false
  validates :id, uniqueness: true
  validate :duplicate_check

  validate do
    if content.blank? && url.blank?
      errors.add(:base, 'Submit a URL or Content')
    end
    if content.present? && url.present?
      errors.add(:base, 'Submit a URL or Content but not Both.')
    end
  end
  validates :url, url: {allow_nil: true, allow_blank: true}

  def to_param
    uri
  end

  def duplicate_check
    existing = self.class.find_by(url: url)
    if existing      
      errors.add :base, "Sorry, this URL has already been added, but you can vote/comment on it here: <a href='/discuss/#{existing.uri}'>https://starterpad.com/discuss/#{existing.uri}</a>".html_safe
    end
  end

  scope :active, -> { where(disabled: false) }
  scope :disabled, -> { where(disabled: true) }
  scope :newest, -> { order(score: :desc) }
end
