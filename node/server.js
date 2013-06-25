
//set up the logger
var w = require('winston');
var utils = require('./lib/utils.js');
var bootpack = require('./lib/boot.js');

var io = bootpack.start_io()
var redis = bootpack.start_redis()

io.on('connection',function(socket){
		
	//grab cookie on connection
	cookie_obj = utils.get_cookies(socket)
	
	if( !cookie_obj['switch_b_stream_token'] ){
		w.warn('request did not have stream token')
		socket.emit('token:missing');
		socket.disconnect();
		return;
	}

	w.info('verifying token: '+cookie_obj['switch_b_stream_token']);
	
	redis.main.hgetall( 'switchb_conn_'+cookie_obj['switch_b_stream_token'],function(err, reply){
		if(!reply.stream_channel){
			w.warn('stream token is not registered')
			socket.emit('token:unknown');
			socket.disconnect();
			return;
		}
		subscribe_to_stream( socket, reply.stream_channel )
	})
	
})

var subscribe_to_stream = function(socket, stream_channel ){
	//tie into redis pusub
	w.info('subscribing to '+stream_channel)
	
	//when messages are received....
	redis.sub.on('message',function(channel, message){
		process_stream_message(socket, channel, message )		
	})
	//subscribe to channel
	redis.sub.subscribe( stream_channel )
}

var process_stream_message = function( socket,channel, message ){
	w.info('processing incmoning redis message')
	event_arr = JSON.parse( message )
	
	if( event_arr.length >0 ){
		socket.emit('switchb_event',event_arr)	
	}
	
}


