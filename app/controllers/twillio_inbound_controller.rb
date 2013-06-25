class TwillioInboundController < ApplicationController
	def sms
		message_body = params["Body"]
		from_number = params["From"]
		@event = Event.create(:verb => 'inbound_sms' , :params => { :from => from_number, :body => message_body })
	end

  def call
    from_number = params["From"]
    from_city  = ( true && params["FromCity"] ) || 'nowhere'
    call_sid = params['CallSid']
    call_status = params['CallStatus']
    logger.info 'inbound call from '+from_number.to_s
    # see if caller exists
    the_caller = Caller.where( :number => from_number ).first

    if not the_caller
      #create a new caller
      the_caller = Caller.create( :number => from_number )
      the_caller.broadcast_new

      # welcome them and redirect to start recording
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Hello, caller from '+ from_city, :voice=>'woman'
        r.Redirect 'start_recording'
      end
    else
      the_calls = the_caller.calls
      the_caller.broadcast_calling
      #welcome back redirect to menu
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Welcome back!', :voice=>'woman'
        r.Say 'You have told me '+the_calls.length.to_s+' secrets', :voice=>'woman'
        r.Redirect 'call_in_options'
      end
    end
    #make a record of the call
    the_call = Call.create(
      :twillio_sid => call_sid,
      :status => call_status,
      :caller_id => the_caller.id
      ).incoming

    

  	render :xml => response.text
  end

  def call_in_options
    call_sid = params['CallSid']
    call_status = params['CallStatus']

    the_call = Call.by_sid(call_sid)
    the_call.status=call_status
    the_call.save



    #present options for the caller
    response = Twilio::TwiML::Response.new do |r|
      r.Gather :action=>'call_in_select' ,:finishOnKey=>'any digit' ,:numDigits=>'1' do |g|
        g.Say 'Press 1 to listen to secrets', :voice=>'woman'
        g.Say 'Press 2 to tell me another secret', :voice=>'woman'
      end
      r.Say 'Sorry I did not understand your answer', :voice=>'woman'
      r.Redirect 'call_in_options'
    end
    render :xml => response.text
  end

  def call_in_select
    from_number = params["From"]
    digits = params["Digits"]
    call_sid = params['CallSid']
    call_status = params['CallStatus']

    the_call = Call.by_sid(call_sid)
    the_call.status=call_status
    the_call.save



    if digits == '1'
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect 'listen'
      end
    elsif digits=='2'
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect 'start_recording'
      end
    else
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Sorry I did not understand your answer', :voice => 'woman'
        r.Redirect 'call_in_options'
      end
    end
    render :xml => response.text

  end
 
  def start_recording
    from_number = params["From"]
    call_sid = params['CallSid']
    call_status = params['CallStatus']

    the_call = Call.by_sid(call_sid)
    the_call.status=call_status
    the_call.save

    the_call.start_recording

    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Tell me a secret, after the beep.', :voice => 'woman'
      r.Record :action=>'finish_recording', :maxLength => 60
    end
    
    render :xml => response.text
  end
  
  def listen
    from_number = params["From"]
    call_sid = params['CallSid']
    call_status = params['CallStatus']
    
    the_call = Call.by_sid(call_sid)
    the_call.status=call_status
    the_call.save

    the_caller = Caller.where( :number => from_number ).first
    the_calls = the_caller.calls
    s_count = the_calls.length


    if not the_caller
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Sorry, I do not know who you are!'
        r.Redirect 'call_in_options'
      end
    end

    the_secrets = Call.where([
       "calls.caller_id IS NOT ?", the_caller.id,
       "calls.rec_url IS NOT ?",nil]
      ).order("RANDOM()").first( s_count )

    played_count = 1
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'You have told me '+s_count.to_s+' secrets', :voice=>'woman'
      r.Say 'You will now hear up to '+s_count.to_s+' secrets from other callers' , :voice=>'woman'
      the_secrets.each do |s|
        r.Say 'Secret number '+played_count.to_s
        r.Play s.rec_url
        played_count+=1
      end
      r.Say 'Those were all the secrets, call back later to hear more', :voice=>'woman'
      r.Redirect 'call_in_options'
    end
    render :xml => response.text

  end
  

  def call_end
    call_sid = params['CallSid']
    call_status = params['CallStatus']
    the_call = Call.by_sid(call_sid)
    the_call.status = call_status
    the_call.hangup
    render :xml => nil

  end
  def finish_recording

    # evaluate the recording
    rec_url = params["RecordingUrl"]
    rec_length = params["RecordingDuration"]
    from_number = params["From"]
    call_sid = params['CallSid']
    call_status = params['CallStatus']

    #look up the call
    the_call = Call.by_sid(call_sid)


    if not the_call
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Sorry, I do not know who you are!'
        r.Redirect 'call_in_options'
      end
    end
    
    the_call.finish_recording( rec_url, rec_length )

    # build up a response
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Thank You', :voice=>'woman'
      r.Say 'Your secret is NOT safe with us!', :voice=>'woman'
      r.Redirect 'call_in_options'
    end
    render :xml => response.text

  end
end
