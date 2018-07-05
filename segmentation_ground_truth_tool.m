%tool to help label ground truth for training an image segmentation neural network

%DONE: findout what format the output should be in. It should be a mask
%TODO: create gui which does the following
% / loads images from a folder one after the other
% / overlays superpixels
% / allows adaptation of superpixels (algorithm, size, compactness)
% / allow zoom & pan
% - select label from a list
% / add label to a list
% - remove label from a list
% - click superpixels to apply label
% - saves labels as mask
% - load existing mask and overplot
% - save/load a set of labels

%credit where credit's due: inspired by Viulib from Vicomtech
%https://www.youtube.com/watch?v=xBUT4nJDh20

%TODO (seems impossible with appdesigner)
% - keyboard shortcuts (next image, zoom/select). maybe with UIFigure.WindowKeyPressFcn
% - hover text
% - fix axes size