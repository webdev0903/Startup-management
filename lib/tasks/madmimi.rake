namespace :madmimi do
  desc "Import all VALID users to MadMimi"
  task import_all_new: :environment do
  	mimi = MadMimi.new(Settings.madmimi.email, Settings.madmimi.key)
  	list = 'New Users'
  	confirmed_users = User.where(['confirmed_at IS NOT NULL AND created_at > ?', Time.parse('2015-01-24')]).
  	select(:email, :title, :current_sign_in_ip).
  	map { |c| {:email => c.email, :name => c.title, :ip => c.current_sign_in_ip, :add_list => list} }
  	puts "Users found: #{confirmed_users.size}"
  	mimi.add_users(confirmed_users)
  end

end
