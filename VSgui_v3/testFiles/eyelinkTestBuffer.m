%Sample code from SR support forum:
       % start recording eye position (preceded by a short pause so that 
        % the tracker can finish the mode transition)
        % The paramerters for the 'StartRecording' call controls the
        % file_samples, file_events, link_samples, link_events availability
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.05);
        Eyelink('StartRecording', 1, 1, 1, 1);    
        % record a few samples before we actually start displaying
        % otherwise you may lose a few msec of data 
        WaitSecs(0.1);
       
        
        eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
        if eye_used == el.BINOCULAR; % if both eyes are tracked
            eye_used = el.LEFT_EYE; % use left eye
        end



        lastSampleTime = 0;

        % STEP 7.5
        % Monitor the trial events;
        while 1 % loop till error or space bar is pressed
            % Check recording status, stop display if error
            error=Eyelink('CheckRecording');
            if(error~=0)
                break;
            end
            
            % looping through link events.
            for i=1:100
		    type = Eyelink('getnextdatatype');
		    if type == 200 % samples
			evt = EyeLink('getfloatdata', type);

			if eye_used ~= -1 % do we know which eye to use yet?
			    if evt.time > lastSampleTime
			    	x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
			    	y = evt.gy(eye_used+1);
			     end
			    lastSampleTime = evt.time
						 
			end % if eye_used ~= -1 
		    end  % if type == 200 % samples
            end %for i=1:100
            
            Eyelink('Message', 'getnextdatatype calls checked at sample time %d', lastSampleTime);
 
        end % main loop

        % adds 100 msec of data to catch final events
        WaitSecs(0.1);
        % stop the recording of eye-movements for the current trial
        Eyelink('StopRecording');