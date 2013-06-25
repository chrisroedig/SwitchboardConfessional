var _ = require('underscore')
module.exports.get_cookies = function( socket ){
	
	var output={};
	var cookies = socket.handshake.headers.cookie.trim().split(';');
	_.each( cookies , function(c){
		
		kv = c.split('=')
		
		output[ kv[0].trim() ] = kv[1].trim()
	});
	return output
}