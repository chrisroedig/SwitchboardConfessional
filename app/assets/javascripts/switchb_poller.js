//polling client event dispatcher

SwitchB.EventSources = SwitchB.EventSources||{}

//basis for all dispatcher objects
SwitchB.EventSources.Poller = {

	cycle_time : 5,//in seconds

	initialize : function(){
		_.bindAll( this );
		SwitchB.log('starting event poll')	
		this.schedule_poll()
	},

	poll_timer: null,

	schedule_poll:function(){
	
		this.poll_timer = setTimeout(this.do_poll, this.cycle_time * 1000 )
	},

	do_poll:function(){
		
		$.ajax('/events',{
			type:'GET',
			dataType:'json',
			data:{
				lookback: this.cycle_time 
			},
			success:this.poll_response
		})
		this.schedule_poll()
	},

	poll_response:function(d){
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


