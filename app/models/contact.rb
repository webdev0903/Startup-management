class Contact
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include Humanizer

  attr_accessor :name, :email, :subject, :message, :bypass_humanizer

  validates :name, :email, :subject, :message, :presence => true
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validate :humanizer_check_answer, :unless => :bypass_humanizer

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def inform_support
    SupportMailer.inform_support(self).deliver
  end

end