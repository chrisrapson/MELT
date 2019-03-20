function stringOut=titleify(stringIn)
% makes strings compatible with the title format
% Useful if I want underscores and carets to 
% appear as underscores and carets.
%
% See also: latexify bashify simulinkify

%Author: Chris Rapson

if ~isempty(stringIn)
	illegalChars='_^';
	replacementChars=[{'\_'},{'\^'}];

	for i=1:length(illegalChars)
			stringIn=strrep(stringIn,illegalChars(i),replacementChars{i});
	end
end

stringOut=stringIn;
return          