function stringOut=titleify(stringIn)
% makes strings compatible with the title format
% Useful if I want underscores and carets to 
% appear as underscores and carets.
%
% See also: latexify bashify simulinkify

%Author: Chris Rapson

illegalChars='_^';
replacementChars=[{'\_'},{'\^'}];

for i=1:length(illegalChars)
    stringIn=strrep(stringIn,illegalChars(i),replacementChars{i});
end
% for i=1:length(illegalChars)
%     maxJ=length(stringIn);
%     j=1;
%     while j<=maxJ% j=1:maxJ%length(stringIn)
%         n=length(replacementChars{i});
%         if strcmp(stringIn(j),illegalChars(i))
%             stringIn=[stringIn,sprintf('%d',ones(1,n-1))];
%             stringIn(j+n:end)=stringIn(j+1:end-n+1);
%             stringIn(j:j+n-1)=replacementChars{i};
%             maxJ=length(stringIn);
%         end
%         j=j+1;
%     end
% end

stringOut=stringIn;
return          