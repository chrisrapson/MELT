%estimate brightness
img_files = dir('H:\CR\Projects\2018_vehicle_light_detection\lab_exp\trailer_lights\20180702\fixed_exposure\*.jpg');
for ii=length(img_files):-1:1
	img(ii) = load(fullfile(img_files(ii).folder), img_files(ii).name));
end

%% identify pixels
%for vehicles, this part will be done by machine learning


%% calculate representative brightness
%average?
%median?
%max?
%upper quartile?