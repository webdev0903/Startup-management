$(function(){
	function Tracker(){
		var user = {}
		var log = window.console? console.log.bind(console, 'Tracker:') : function(){}

		function updateProfile(config){
			config = config || {}
			try{
				user = JSON.parse($('#user').val())	
				if(config.alias)	
					mixpanel.alias(user.id.toString())
				
				mixpanel.identify(user.id)
				mixpanel.people.set({
				    '$name': user.title,
				    '$email': user.email
				})		
			}
			catch(e){
				log('User not found.')
			}	
		}
		updateProfile()

		return {
			emit : function(eventName, data){
				data = data || {}
				data.$referrer = window.location.href

				switch(eventName){
					case 'Signup': 
						updateProfile()
						break
					default:
					  break
				}

				mixpanel.track(eventName,data)
			}
		}
	}


	window.tracker = new Tracker()
});