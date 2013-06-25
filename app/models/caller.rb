class Caller < ActiveRecord::Base
  attr_accessible :id,:last_call_at, :number
  has_many :calls, :dependent => :destroy
  has_many :events
  

  def broadcast_new
  	#broadcast the new caller
  	caller_count = Caller.count()
  	
  	call_event = Event.new(
  			:verb						=>'caller_new',
  			:feed_level			=>40,
  			:storage_level	=>40,
  			:caller_id			=>self.id
  	).publish

  	Event.new(
  			:verb						=>'global_update',
  			:feed_level			=>30,
  			:storage_level	=>30,
  			:globals				=>{
  				:total_callers=>{
  					:value	=> caller_count
  				}
  			}
  	).publish
  	 
  end

   def broadcast_calling
  	#broadcast the new caller
  	call_count = Caller.count()
  	
  	Event.create(
  			:verb						=>'caller_calling',
  			:feed_level			=>40,
  			:storage_level	=>40,
  			:caller 				=>self
  	).publish
  	
  	return 
  end
end
