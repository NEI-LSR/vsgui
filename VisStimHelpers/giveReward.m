function giveReward(open_time, ex)
    % giveReward(open_time)
    % giveReward activates the peristaltic pump for
    % the duration open_time (in secs, minimum open_time is 0.012)
    % (sets the first pin of the digital out to high for the desired duration)
    %
    %  history
    %
    % 10/29/13  hn    Written

    if nargin > 1
        Datapixx('SetDoutValues',ex.strobe.REWARD);
        Datapixx RegWrRd
        pause(open_time);
        Datapixx('SetDoutValues',0);
        Datapixx RegWrRd

    else

        %Datapixx('Open');  % comment out later on
        Datapixx('SetDoutValues',1);
        Datapixx RegWrRd
        pause(open_time);
        Datapixx('SetDoutValues',0);
        Datapixx RegWrRd
        %Datapixx('Close') %comment out later on

    end
