class Call < ActiveRecord::Base
  attr_accessible :id,:caller,:caller_id,:rec_length, :rec_url,:play_length, :play_count,:twillio_sid,:status
  belongs_to :caller
  has_many :events
  
  def self.by_sid(call_sid)
  	self.where(:twillio_sid=>call_sid).first()
  end

  def incoming
  	#broadcast start of the call
  	call_count = Call.count()
  	
  	call_event = Event.new(
  			:verb						=>'call_incoming',
  			:feed_level			=>40,
  			:storage_level	=>40,
  			:call_id  			=>self.id,
        :caller_id      =>self.caller_id,
  	)
  	call_event.publish

  	Event.new(
  			:verb						=>'global_update',
  			:feed_level			=>30,
  			:storage_level	=>30,
  			:globals				=>{
  				:total_calls=>{
  					:value	=> call_count
  				}
  			}
  	).publish
  end
  def hangup
  	  	call_event = Event.new(
  			:verb						=>'call_hangup',
  			:feed_level			=>40,
  			:storage_level	=>50,
  			:call_id  			=>self.id,
        :caller_id      =>self.caller_id
  	)
  	call_event.publish
  end
  def start_recording
  	call_event = Event.new(
  			:verb						=>'call_recstart',
  			:feed_level			=>40,
  			:storage_level	=>30,
  			:call_id			=>self.id,
        :caller_id      =>self.caller_id
  	).publish

  end

	def finish_recording( rec_url, rec_length )
  	write_attribute(:rec_url,rec_url)
  	write_attribute(:rec_length,rec_length)
  	
  	
  	self.save

  	min_rec = Call.sum( :rec_length ) / 60.0

  	call_event = Event.new(
  			:verb						=>'call_recfinish',
  			:feed_level			=>40,
  			:storage_level	=>30,
  			:call_id			=>self.id,
        :caller_id      =>self.caller_id
  	).publish

  	Event.new(
			:verb						=>'global_update',
			:feed_level			=>30,
			:storage_level	=>30,
			:globals				=>{
				:minutes_rec=>{
					:value	=> min_rec
				}
			}
  	).publish

  end


end
