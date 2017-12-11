# == Schema Information
#
# Table name: cofounders
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#  startup_id :integer
#

class Cofoundership < ActiveRecord::Base

  self.table_name = 'cofounders'

  attr_accessible :startup_id, :user_id

  #has_one :notification, :dependent => :destroy
  has_one :notification, :dependent => :destroy, :foreign_key => :cofounder_id
  
  belongs_to :user
  belongs_to :startup
  
  validates_uniqueness_of :user_id, :scope => [:startup_id]
  validate :status_of_user_must_active

  private
    def status_of_user_must_active
      errors.add(:user, I18n.t('.errors.messages.user_is_not_active')) if user && !user.status?
    end

end
