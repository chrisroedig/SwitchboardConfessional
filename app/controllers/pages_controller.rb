class PagesController < ApplicationController
	layout 'splash'
  def home
  	#todo: obfuscate phone numbers
  	@calls = Call.all()
  	@callers = Caller.all()
  	@events = Event.all() 

  	minutes_rec = Call.sum( :rec_length ) / 60.0
  	minutes_play = Call.sum( :play_length ) / 60.0

    @globals = {
    :total_callers  =>   { :title  => 'Unique Callers', :value => Caller.count(), :unit =>'callers'},
  	:total_calls =>   { :title  => 'Inbound Calls', :value => Call.count(), :unit => 'calls'	},
  	:total_sms =>  { :title  => 'Inbound SMS', :value => 0, :unit => 'messages'	},
  	:minutes_rec =>  { :title  => 'Recorded', :value => minutes_rec , :unit => 'minutes'	},
 	 	:minutes_play =>  { :title  => 'Played Back', :value => minutes_play, :unit => 'minutes'},
  	}

    @node_config = {
      :host=>Rails.application.config.node[:external_host],
      :port=>Rails.application.config.node[:external_port],
    }

    if not cookies[:switch_b_stream_token]
      # stream server connection consists of a hash with a channel name and a token
      # the channel can be whatever scope is needed for proper info seperation
      token_str =Digest::SHA1.hexdigest(Time.now.to_s)

      #construct an array of info about the client
      client_info = {
        :stream_channel => 'switchb:events:main',
        :stream_token => token_str
      }
      
      #set the connection info as json into the cookie
      cookies[:switch_b_stream_token] = token_str
        

      #register this unique token as a hash in redis
      $redis.hmset(
        'switchb_conn_'+token_str, 
        'stream_channel', client_info[:stream_channel]
      )


    end


  end
end
