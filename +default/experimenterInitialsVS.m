function initials = experimenterInitialsVS;
% function initials = experimenterInitialsVS;
%
% +default.experimenterInitialsVS
%
% helper function for the experimenter_callback function in VS-toolbox to make
% sure that the experimenter initials have a a pre-defined format
% formerly: function initials = getExperimenterInitials(ex)
%
% history
% 12/02/20: updated for NIH group members
% 08/15/25: removed 'ex' from input as not used
% 02/11/26  moved to +default package

initials = 'XX';
taken_initials = {'HN','IK','AL','EM','LH','CL','SC','KK','KQ','PP','AK','JK','BT','CJ','LC','CZ'};

initials = inputdlg('what are your initials?');
initials = upper(initials);
while isempty(initials)
    initials = inputdlg( 'Choose your initials.');
    initials = upper(initials);
end
idx = find(strncmp(initials{1},taken_initials,2));
if ~isempty(idx)
    initials = taken_initials{idx}; 
end
        

