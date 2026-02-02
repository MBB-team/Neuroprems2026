function [] = DrawMyText(window,textstring,textsize,textcol,textcenter,varargin)
% DrawMyText - personalized DrawFormattedText parametrization
% Nicolas Borderies
% February 2017

if nargin == 6; wrapat = varargin{1};



elseif nargin > 6; error('too many input arguments')
else; wrapat=60;
end
Screen('TextSize', window, textsize);
[w,h]=RectSize(Screen('TextBounds',window,textstring));
DrawFormattedText(window, textstring,textcenter(1)-w/2, textcenter(2)-h/2,textcol, wrapat, 0, 0, 1, 0, []);

end