class UserRolesController < ApplicationController
	def update_users_count
		roles = User::Role.all
		roles.each do |role|
			users_count = User::Profile.where('user_role_id'=>role.id).count
			r = User::Role.find_by_id(role.id)
			r.users_count = users_count
			r.save
		end
	end
end
