%tool to help label ground truth for training an image segmentation neural network

%credit where credit's due: inspired by Viulib from Vicomtech
%https://www.youtube.com/watch?v=xBUT4nJDh20

%DONE: findout what format the output should be in. It should be a mask
%TODO: create gui which does the following
% / loads images from a folder one after the other
% / overlays superpixels
% / allows adaptation of superpixels (algorithm, size, compactness)
% / allow zoom & pan
% / select label from a list
% / add label to a list
% / remove label from a list
% / click superpixels to apply label
% / saves labels as mask
% / load existing mask and overplot
% / save/load a set of labels
% - keyboard shortcuts (next image, zoom/select). maybe with UIFigure.WindowKeyPressFcn
% - hover text (seems impossible with appdesigner)
% / fix axes size
% / polygons
% - smart polygons? Superpixels need less clicks, but edges aren't as smooth as smart polygons.
% / brush size
% - show thin superpixel borders, not full pixel width
% - opacity
% / slider for label buttons
% - ignore mask files (but watch out for files which coincidentally have the same name format?)
% - load the image just once and store it in UserData