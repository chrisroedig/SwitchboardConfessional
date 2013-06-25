SwitchB.EventSources=SwitchB.EventSources||{}

//basis for all dispatcher objects
SwitchB.EventSources.Socket = {
	socket:null,
	initialize:function(){
		_.bindAll( this );
		var url = 'http://'+SwitchB.node_config.host+':'+SwitchB.node_config.port

		SwitchB.log('connecting to socket.io at '+url)

		this.socket = io.connect(url)
		this.socket.on('switchb_event',this.handle_events)
	},
	handle_events:function( d ){
		
		if( d.length < 1 ){
			return; //no events
		}
		_.each(d,function( ev_obj ){
			//try to run a responder
			if( SwitchB.server_stream_responders[ ev_obj.verb ] === undefined ){
				//responder not defined
				SwitchB.server_stream_responders.default( ev_obj )
			}else{
				//responder defined
				SwitchB.server_stream_responders[ ev_obj.verb ]( ev_obj )
			}		
		})
		//run on events callback
		this.on_events( d )
	},
	on_events:function(event_arr){
		//use this to do some kind of global indication	
	}

}