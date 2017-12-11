# == Schema Information
#
# Table name: user_roles
#
#  id     :integer          not null, primary key
#  title  :string(500)
#  slug   :string(500)
#  nb     :integer          default(0)
#  plural :string(500)
#

class User::Role < ActiveRecord::Base

  has_many :profiles, :foreign_key => 'user_role_id'
  
end
