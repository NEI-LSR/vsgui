function [animal, animalPrefix] = animalName(varargin);
%
% function [animal, animalPrefix] = animalName(varargin);
%
% +default.animalName
%
% These definitions were previously included in 'getDefaultSettings.m' but
% I moved them here for better readability of the code.
% This function is called by 'getDefaultSettings.m'.
% animal names are stored in ex.Header.animal.XX
% animal prefixes are stored in ex.setup.filePrefix.XX
%
% history
% 08/15/25: wrote it
% 02/11/26  hn: moved to +package

if nargin==0
    idlg = inputdlg('Enter first two letters of monkey name','Subject');
    animalPrefix = idlg{1};
    if length(animalPrefix)<2
        animalPrefix = 'xx';
    else animalPrefix = lower(animalPrefix(1:2));
    end
else 
    animalPrefix = varargin{1};
    if ~ischar(animalPrefix) || length(animalPrefix)<2
        animalPrefix = 'xx';
    else
        animalPrefix = lower(animalPrefix(1:2));
    end
end

switch lower(animalPrefix)
    case 'ad'
        animal = 'adams';
    case 'ki'
        animal = 'kiwi';
    case 'ma'
        animal = 'mango';
    case 'le'
        animal = 'lemieux';
    case 'ba'
        animal = 'barnum';
    case 'sh'
        animal = 'shocktop';
    case 'hu'
        animal = 'hummus';
    case 'te'
        animal = 'tempura';    
    case 'ta'
        animal = 'tamago';            
    case 'jo'
        animal = 'jocamo';    
    case 'ka'
        animal = 'kaki';  
    case 'ly'
        animal = 'lychee'; 
    otherwise
        animal = 'test';
        animalPrefix = 'xx';
end