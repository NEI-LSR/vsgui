function [calibration_result]=calibrateLR(ex,portNumber)

% history
% 2021.03.10 ik:revised to use PR655 instead of PR670

% tip for checking the USB serial port
% on Linux, the portNumber are usually '/dev/ttyACM0' or 
% '/dev/ttyACM1'
% On terminal, 'ls -l /dev/tty*' will list all tty files.  Compare the
% lists before and after connecting the USB cable.
% If PR655init('/dev/ttyACM0') runs successfully and set the
% photometer to the remote mode, it returns ' REMOTE MODE'

% PR655Toolbox copied from PsychToolbox/PsychHardware/, so that we can
% modify the scripts.
% PR655measxyz.m was modified to avoid an error
addpath('/usr/share/Code/PR655Toolbox');

calibration_result=[];
samples=[0:4:255,255];
randomised_order=samples(randperm(numel(samples)));

%Point photometer to left target
instruction_1=['Point photometer towards the centre of the target, through the LEFT filter.',...
    'Block Right filter. Adjust zoom to focus clearly. Switch off all lights.',...
    'Close booth. When ALL steps are completed press any key to continue.'];
nested_draw_bulls_eye(ex,instruction_1);
disp(instruction_1);
pause()

start_time1=nested_time_now();
disp(['Started:',start_time1]);

if nargin == 1
    PR655init();
else
    PR655init(portNumber);
end


h=waitbar(0,'Calibration in progress (LEFT)');
%LEFT EYE
%first test left eye with pic in left eye (for gamma correction)
mini_test=[0:20:250];
%randomised_order=mini_test
left_eye_gamma=nan(1,numel(randomised_order));
left_eye_gamma_qual=nan(1,numel(randomised_order));
for index_intensity=1:numel(randomised_order)
    iteration=['Left',int2str(index_intensity),'/',int2str(numel(randomised_order))];
    value=randomised_order(index_intensity);
    nested_display_left_right(ex,'left',value);
    [measure, qual] =nested_measure();
    left_eye_gamma(value==samples)=measure;
    left_eye_gamma_qual(value==samples)=qual;
    pause(1)
    waitbar(index_intensity/numel(randomised_order),h,iteration);
end


%second measure cross-talk in left eye 
left_eye_crosstalk=[];
nested_display_left_right(ex,'right',255);
measure=nested_measure();
left_eye_crosstalk=measure;
pause(1)
end_time1=nested_time_now();
disp(['Started left:',start_time1,'End left',end_time1]);

instruction_2=['Move photometer to point through the RIGHT filter towards the centre of the target.',...
       'Block left filter. Check focus. Switch off all lights.',...
       'Close booth. When ALL steps are completed press any key to continue.'];
nested_draw_bulls_eye(ex,instruction_2);
disp(instruction_1);
pause()

start_time2=nested_time_now();
disp(['Started left:',start_time1,'End left:',end_time1,'Started right: ',start_time2]);

h=waitbar(0,'Calibration in progress (RIGHT)');
%RIGHT EYE
%first test right eye with pic in right eye (for gamma correction)
mini_test=[0:20:250];
%randomised_order=mini_test
right_eye_gamma=nan(1,numel(randomised_order));
right_eye_gamma_qual=nan(1,numel(randomised_order));
for index_intensity=1:numel(randomised_order)
    iteration=['Right',int2str(index_intensity),'/',int2str(numel(randomised_order))];
    value=randomised_order(index_intensity);
    nested_display_left_right(ex,'right',value);
    [measure,qual] = nested_measure();
    right_eye_gamma(value==samples)=measure;
    right_eye_gamma_qual(value==samples)=qual;
    pause(1)
    waitbar(index_intensity/numel(randomised_order),h,iteration);
end


%second measure cross-talk in right eye (by presenting stuff in left eye) 
right_eye_crosstalk=[];
nested_display_left_right(ex,'left',255);
measure=nested_measure();
right_eye_crosstalk=measure;
pause(1)

end_time2=nested_time_now();
time=['Started left:',start_time1,'End left: ',end_time1,...
      'Started right:',start_time2,'End right: ',end_time2];
  
calibration_result.left_eye_gamma=left_eye_gamma;
calibration_result.left_eye_crosstalk=left_eye_crosstalk;
calibration_result.left_eye_gamma_qual=left_eye_gamma_qual;
calibration_result.right_eye_gamma=right_eye_gamma;
calibration_result.right_eye_crosstalk=right_eye_crosstalk;
calibration_result.right_eye_gamma_qual=right_eye_gamma_qual;
calibration_result.values=samples;
calibration_result.L_filter_computed_crosstalk=right_eye_crosstalk./left_eye_gamma(end);
calibration_result.R_filter_computed_crosstalk=left_eye_crosstalk./right_eye_gamma(end);
calibration_result.time=time;
  
disp(time);  
nested_display_blank(ex);
PR655close();

end




%%%%%%%%%%%%%%%%%%



%Nested functions




%%%%%%%%%%%%%%%%%%


function [output,qual] = nested_measure()
%return Y: luminance intensity
%programmed to work with PR655
[XYZ, qual]=PR655measxyz();      
output=XYZ(2);
%output=1

end



function nested_display_left_right(ex,leftRight_string,intensity)
%function display value: intensity in eye specified in second parameter
%displays blank screen in other eye.
blank=[0,0,0];
specified_RGB=[intensity,intensity,intensity];

switch leftRight_string
    case 'left'
    draw_eye=0;empty_screen=1;
    case 'right'
    draw_eye=1;empty_screen=0;    
    otherwise    
    error('Incorrect eye (use left or right as second parameter).');
end

Screen('SelectStereoDrawBuffer', ex.setup.window, draw_eye);
Screen('FillRect',ex.setup.window,specified_RGB);
Screen('SelectStereoDrawBuffer', ex.setup.window, empty_screen);
Screen('FillRect',ex.setup.window,blank);
Screen('Flip',  ex.setup.window);
end

function nested_display_blank(ex)
blank=[0,0,0];
%draw blank screens for both eyes
Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
Screen('FillRect',ex.setup.window,blank);
Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
Screen('FillRect',ex.setup.window,blank);
Screen('Flip',  ex.setup.window);
end 

function nested_draw_bulls_eye(ex,the_text)
nested_display_blank(ex);
%size of screen
[out]=Screen('Rect',ex.setup.window);
centrex=out(3)/2;                   centrey=out(4)/2;

circle_list=[10,20,30,40,50,100,150,160,170,180,190,200,...
    250,300,400,420,440,460,480,500,600,650,700,800,900,1000,1010,1020];
%draw midlines
nested_draw_line(ex,out(1),centrey,out(3),centrey);
nested_draw_line(ex,centrex,out(2),centrex,out(4));
%add text if specified
if ~isempty(the_text)
nested_write_text(ex,out(1)+80,out(2)+600,the_text)
end

for i=1:numel(circle_list)
nested_draw_circle(ex,centrex,centrey,circle_list(i));
end
Screen('Flip',  ex.setup.window);
end


function nested_draw_circle(ex,centrex,centrey,size_circle)
size=size_circle/2;
Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
Screen('FrameOval',ex.setup.window,[255 ],[centrex-size centrey-size centrex+size centrey+size ]);
Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
Screen('FrameOval',ex.setup.window,[255 ],[centrex-size centrey-size centrex+size centrey+size ]);
end

function nested_write_text(ex,start_x,start_y,the_text)

Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
Screen('DrawText',ex.setup.window,the_text,start_x,start_y,255);
Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
Screen('DrawText',ex.setup.window,the_text,start_x,start_y,255);

end

function nested_draw_line(ex,start_x,start_y,end_x,end_y)

Screen('SelectStereoDrawBuffer', ex.setup.window, 0);
Screen('DrawLine',ex.setup.window,[255 ],start_x,start_y,end_x,end_y);
Screen('SelectStereoDrawBuffer', ex.setup.window, 1);
Screen('DrawLine',ex.setup.window,[255 ],start_x,start_y,end_x,end_y);

end

function [nice_format]=nested_time_now()
[old]=clock;
year=old(1);    month=old(2);   day=old(3);
hours=old(4);   minutes=old(5); seconds=old(6); 

nice_format=[int2str(hours),':',int2str(minutes),':',int2str(seconds),', ',...
    int2str(day),'/',int2str(month),'/',int2str(year)];

end


