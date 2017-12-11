# == Schema Information
#
# Table name: email_settings
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  private_messages :boolean
#  morning_mail     :boolean
#  last_email_at    :datetime
#  next_email_at    :datetime
#  emails_count     :integer
#  admin_emails     :integer
#  confirmed_emails :integer
#  welcome_emails   :integer
#  hash_code        :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  google           :boolean
#  subscription     :boolean
#

class User::Setting < ActiveRecord::Base

  self.table_name = 'email_settings'
  self.primary_key = :id 
  belongs_to :user

	attr_accessible :google, :morning_mail, :private_messages, :subscription, :user_id, :discuss_trending, :startup_update_reminder

 	def subscription=(value)
 		super(value)
 		user = {
 			:email => self.user.email,
 			:ip => self.user.current_sign_in_ip,
 			:name => self.user.title
 		}
 		update_madmimi(user, self.subscription ) if self.subscription_changed?
 	end

  def discuss_trending=(value)
    super(value)
    user = {
      :email => self.user.email,
      :ip => self.user.current_sign_in_ip,
      :name => self.user.title
    }
    update_madmimi(user, self.discuss_trending, "Discuss - Trending Items" ) if self.discuss_trending_changed?
  end

 	protected

 	def update_madmimi(user,value,list="New Users")
 		mimi = MadMimi.new(Settings.madmimi.email, Settings.madmimi.key)
  	if value
  		user[:add_list] = list
  		mimi.add_user(user)
  	else
	  	mimi.remove_from_list(user[:email], list)
	  end
 	end
end
