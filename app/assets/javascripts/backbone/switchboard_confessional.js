//= require_self
//= require_tree ./templates
//= require_tree ./models
//= require_tree ./views
//= require_tree ./routers

window.SwitchB = {
	Models: {},
  Collections: {},
  Routers: {},
  Views: {},	
}

//log handler, eventually this gets silenced
SwitchB.log = function( lstr ){
	console.log( lstr )
}

//SERVER STEAM RESPONDERS

//each event carries a "verb"
//that verb points to a responder
SwitchB.server_stream_responders = {}

//respon to unhandled events
SwitchB.server_stream_responders.default = function( event_obj ){
	SwitchB.log( 'default stream response to: '+event_obj.verb )

}
//respond to global variable updates
SwitchB.server_stream_responders.global_update = function( event_obj ){
	// update the globals
	_.each( event_obj.globals, function(data,key){
		SwitchB.trigger( 'model:scalar:update:'+key, data )
	})

	// put a nostification in the feed
	//SwitchB.feed( event_obj, 'global_update' )

}
//
SwitchB.server_stream_responders.caller_new = function( event_obj ){

	// put a nostification in the feed
	SwitchB.feed( event_obj, 'caller_new' )
}

SwitchB.server_stream_responders.call_incoming = function( event_obj ){

	// put a nostification in the feed
	SwitchB.feed( event_obj, 'call_incoming' )
}

SwitchB.server_stream_responders.call_recstart = function( event_obj ){
	console.log('call_recstart')
	console.log(event_obj)
	// put a nostification in the feed
	SwitchB.feed( event_obj, 'call_recstart' )
}

SwitchB.server_stream_responders.call_recfinish = function( event_obj ){
	console.log('call_recfinish')
	console.log(event_obj)
	// put a nostification in the feed
	SwitchB.feed( event_obj, 'call_recfinish' )
}

SwitchB.server_stream_responders.call_hangup = function( event_obj ){
	// put a nostification in the feed
	SwitchB.feed( event_obj, 'call_hangup' )
}



//DATA EVENT BUS....
SwitchB.bus = $(document) //where data events are bussed, eveybody binds here

//function to trigger data events to models and collections
SwitchB.trigger = function(event_str, data){
	$(document).trigger( event_str, data )
}

//FEED INJECTION 
SwitchB.feed = function( data, template	){
	data.template = template
	

	SwitchB.trigger('model:activity:add',data)
}

