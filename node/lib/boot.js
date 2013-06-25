//get some utility functions
var utils = require('./utils.js');
//yaml parse
var YAML =require('libyaml')

//parse arguments to get operating mode
var args = process.argv.splice(2);
if( args.length < 1 ){ args = ['development'] }
var op_mode = args[0]

//set up the logger
var w = require('winston');
//add file output in rails log dir
w.add( w.transports.File, { filename: '../log/'+op_mode+'-node.log' } );
//if production, stop logging to the console
if( op_mode=='production'){
	w.remove( w.transports.Console );
}

w.info('initializing switchB push server in '+op_mode+' mode')

//prepare a configured redis client
module.exports.start_redis = function(){

	//load yaml file for redis config
	var redis_config = YAML.readFileSync('../config/redis.yml')
	if( !redis_config ){
		throw('could not load redis.yml!!! stopping!!!')
	}
	redis_config = redis_config[0][op_mode]  
	if( redis_config === undefined ){
		throw('did not find redis config for '+open_mode)
	}
	
	w.info('connecting to redis at '+redis_config.host+':'+redis_config.port)
	//set up a redis client
	var redis = require('redis');
	//client dedicated to pub/sub
	var redis_sub_client = redis.createClient( redis_config.port, redis_config.host );
	//client for general redis acitivity
	var redis_client = redis.createClient( redis_config.port, redis_config.host );
	
	//return the prepared clients
	return {
		sub : redis_sub_client,
		main : redis_client
	}

}

//prepare a configured socket.io instance
module.exports.start_io = function(){

	//load yaml file to get node server config
	var node_config = YAML.readFileSync('../config/node.yml')
	if( !node_config ){
		throw('could not load node.yml!!! stopping!!!')
	}

	node_config = node_config[0][ op_mode ]  

	if( node_config === undefined ){
		throw('did not find node config for ' + op_mode )
	}

	//set up a socket.io listener
	w.info('setting up socket.io to listen at port: '+node_config.internal_port)
	var io = require('socket.io').listen(node_config.internal_port);

	return io

}