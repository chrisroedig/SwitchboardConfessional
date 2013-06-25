class Event < ActiveRecord::Base
  attr_accessible :caller,:call,:broadcast_level, :call_id, :caller_id, :feed_level, :globals, :lifetime,:expires_at, :log_level, :params, :storage_level, :time, :verb
  attr_reader :id
  
  attr_writer :uid
  attr_reader :uid

  serialize :globals
  serialize :params
	belongs_to :call
	belongs_to :caller  
  
  # This model is semi-persistent
  # it's primary purpose is to reference and notify changes to other models 
  # 

  # levels
  # 0 	- everything 
  # 10 	- debug 
  # 20 	- info 
  # 30 	- operational 
  # 40 	- priority  
  # 50 	- critical
  

  # storage:
  # >30 carrier data that could be carried just via push server
  # >40 carries anything that should be stored despite push server

  # feed 
  # > 30 carries silent status updates
  # > 40 and up is visible updates

  # for log 
  # >40 anything worth mentioning (above "info" )

  # broadcast
  # > 40 anything that is needed to keep client working properly

  # examples:
  # chat user goes offline, app has push server
  # feed 30, storage 20, brodcast 40, log 10
	#
	# inbound phone call
	# feed 50, broadcast 50, storage 40, log 10

def lifetime=(time)
  #updating the lifetime also affects the expiration time
  if self.created_at == nil
    self.expires_at = Time.now+time
  else
    self.expires_at = self.created_at + time
  end
  write_attribute(:lifetime, time)
end

after_initialize do |event|
  # unique id for the event
  @uid = ( rand(36**8) + Time.now.to_i ).to_s(36)

  # set the expiration, once the Event is created
  if self.expires_at == nil
    write_attribute(:expires_at, Time.now+event.lifetime)
  end
  if self.created_at == nil
    write_attribute(:created_at, Time.now)
  end
end

before_save do |event|
  #only save to db if the storage level is aobve the storage threshold
  if event.storage_level < Rails.application.config.event_thresholds[:storage]
    return false
  end

end

def publish
  

  if self.storage_level > Rails.application.config.event_thresholds[:storage]
    self.save
  end

  #since non-storage events are missing their associated data
  # we need to reconnect it here


  $redis.publish('switchb:events:main',[self].to_json)

end

def as_json options=nil
  #make sure UID is passed into json
  options ||= {}
  options[:methods] = ((options[:methods] || []) + [:uid,:call,:caller])
  super options
end

end
