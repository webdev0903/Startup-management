require 'mixpanel-ruby'

if Rails.env.production?
	Starterpad::Application.config.tracker = Mixpanel::Tracker.new('5c5a5d01165a26fc258e5d2c96d4e1bb') 
else
	Starterpad::Application.config.tracker = Mixpanel::Tracker.new('7aa3b0b757c3c11b3ffd69125dde1ede') 
end

