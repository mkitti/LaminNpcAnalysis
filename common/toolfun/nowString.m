function str=nowString(mode)
%nowString returns a string containing the current date/time without colons or spaces
%
%SYNOPSIS str=nowString
%
%INPUT    mode: 1) 02-May-2008-11-16-04 - default
%               2) 2008-05-02-11-16-04
%               3) 11-16-04
%              11) 02_May_2008_11_16_04
%              12) 2008_05_02_11_16_04
%              13) 11_16_04
%
%OUTPUT   str: String containing the current date/time without colons or
%              spaces
%
%c: Jonas, 2/03
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1 || isempty(mode)
    mode = 1;
end

switch mod(mode,10)
    case 1
        timeStr=datestr(now);
        timeStr(12)='-'; %there should be no space in filename
        timeStr(findstr(timeStr,':'))='-';

        str=timeStr;
    case 2
        str = datestr(now,31);
        str = regexprep(str,'( |:)','-');
    case 3
        str = datestr(now,31);
        str = regexprep(str(end-7:end),'( |:)','-');
    otherwise
        error('mode %i not defined',mode)
end

if mode > 10
    str = strrep(str,'-','_');
end

