# == Schema Information
#
# Table name: user_facebooks
#
#  id           :integer
#  user_id      :integer
#  title        :string(500)
#  email        :string(500)
#  facebook_id  :integer
#  access_token :string(500)
#  hash         :string(500)
#  last_login   :datetime
#

class User::FacebookAuth < ActiveRecord::Base

  self.table_name = "user_facebooks"
  self.primary_key = :id
  belongs_to :user

end
