class TwillioInboundController < ApplicationController
	def sms
		message_body = params["Body"]
		from_number = params["From"]
		logger.info "inbound sms"
		render :text => "OK"
	end

  def call
    from_number = params["From"]
    from_city  = params["FromCity"]
    logger.info 'inbound call from '+from_number.to_s
    # see if caller exists
    the_caller = Caller.where( :number => from_number ).first

    if not the_caller
      #create a new caller
      the_caller = Caller.create( :number => from_number )
      # welcome them and redirect to start recording
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Hello, caller from '+ from_city, :voice=>'woman'
        r.Redirect 'tw/start_recording'
      end
    else
      the_calls = the_caller.calls
      #welcome back redirect to menu
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Welcome back!', :voice=>'woman'
        r.Say 'You have told me '+the_calls.length.to_s+' secrets', :voice=>'woman'
        r.Redirect 'tw/call_in_options'
      end
    end
  	render :xml => response.text
  end

  def call_in_options
    #present options for the caller
    response = Twilio::TwiML::Response.new do |r|
      r.Gather :action=>'/call_in_select' ,:finishOnKey=>'any digit' ,:numDigits=>'1' do |g|
        g.Say 'Press 1 to listen to secrets', :voice=>'woman'
        g.Say 'Press 2 to tell me another secret', :voice=>'woman'
      end
      r.Say 'Sorry I did not understand your answer', :voice=>'woman'
      r.Redirect 'tw/call_in_options'
    end
    render :xml => response.text
  end

  def call_in_select
    from_number = params["From"]
    digits = params["Digits"]

    if digits == '1'
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect 'tw/listen'
      end
    elsif digits=='2'
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect 'tw/start_recording'
      end
    else
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Sorry I did not understand your answer', :voice => 'woman'
        r.Redirect 'tw/call_in_options'
      end
    end
    render :xml => response.text

  end
 
  def start_recording
    from_number = params["From"]

    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Tell me a secret, after the beep.', :voice => 'woman'
      r.Record :action=>'finish_recording', :maxLength => 60
    end
    
    render :xml => response.text
  end
  
  def listen
    from_number = params["From"]
    the_caller = Caller.where( :number => from_number ).first
    the_calls = the_caller.calls
    s_count = the_calls.length

    if not the_caller
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Sorry, I do not know who you are!'
        r.Redirect 'tw/call_in_options'
      end
    end

    the_secrets = Call.where( "calls.caller_id IS NOT ?", the_caller.id ).order("RANDOM()").first( s_count )
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
      r.Redirect 'tw/call_in_options'
    end
    render :xml => response.text

  end
  


  def finish_recording

    # evaluate the recording
    rec_url = params["RecordingUrl"]
    rec_length = params["RecordingDuration"]
    from_number = params["From"]

    #look up the caller
    the_caller = Caller.where( :number => from_number ).first

    if not the_caller
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Sorry, I do not know who you are!'
        r.Redirect 'tw/call_in_options'
      end
    end

    #create the call
    the_caller.calls.build( :rec_url => rec_url, :rec_length => rec_length)
    the_caller.save

    # build up a response
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Thank You', :voice=>'woman'
      r.Say 'Your secret is NOT safe with us!', :voice=>'woman'
      r.Redirect 'tw/call_in_options'
    end
    render :xml => response.text

  end
end
