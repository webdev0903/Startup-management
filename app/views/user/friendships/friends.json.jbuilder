json.array! @friends do |friend|
	json.id friend.id
	json.title friend.title
	json.url friend.photo.url(:small)
end
