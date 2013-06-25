class EventsController < ApplicationController
  
  def index

  	#grab recent events
    
    if params.has_key?('lookback')
      #updating call:
    
      #has params, updating call, also grabs silent updates
      @events = self.event_update( params['lookback'].to_i )

    else
      #no params: indexing call, fills feed box
      @events = self.event_index
    end

    #respond_to do |format|
      #format.json { render json: @events }
    #end
    render json: @events

  end

  def event_index
    #purpose is to fill up the feed box in the UI
    # events above feed threshold

    min_feed_level = Rails.application.config.event_thresholds[:feed]
    min_bc_level = Rails.application.config.event_thresholds[:broadcast]
 
    Event.where(
      :feed_level => min_feed_level..100,
      :broadcast_level => min_bc_level..100,
      :expires_at =>  Time.new..(Time.new+31536000000)
    ).limit(30)
  end

  def event_update( lookback = 300 )
    # get recent events

    min_bc_level = Rails.application.config.event_thresholds[:broadcast]

  
    Event.where( 
      :broadcast_level => min_bc_level..100,
      :expires_at => Time.new..(Time.new+31536000000)
    ).where([ 'created_at > ?', (Time.new - lookback)] ).limit(30)

  end

  def create  
    @event = Event.new(params[:event])

    $redis.publish('switchb:events:main',[@event].to_json)

    respond_to do |format|
      if @event.publish
        format.json { render json: @event, status: :created, location: @event }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end
  
end
