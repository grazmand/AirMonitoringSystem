classdef VideoManager
    methods (Static)
        function videoMaker(folder, fileType, fileName, bool)
            if bool==true
                % fileType ex.: '*.jpg', '*.png'
                s = strcat(folder, '/', fileType);               
                imagefiles = dir(s);
                nfiles = length(imagefiles); % Number of files found               
                writerObj = VideoWriter(strcat(folder,'/',fileName));
                writerObj.FrameRate = 2;
                open(writerObj);
                disp('video storing:')
                indexProgress = 1;
                for i = 1:nfiles
                    if i>=floor(nfiles/10)*indexProgress
                        fprintf(' %d/%d ',indexProgress,min(nfiles,10));
                        indexProgress = indexProgress + 1;
                    end
                    filename = imagefiles(i).name;
                    thisimage = imread(strcat(folder,'/',filename));
                    if i==1
                        sizePic = size(thisimage);
                        sizePic = sizePic(1:2);
                    else
                        thisimage = imresize(thisimage,sizePic);
                    end
                    writeVideo(writerObj, thisimage);
                end
                close(writerObj);
                fprintf(' \n')
            end
        end
    end
end