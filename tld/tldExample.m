% Copyright 2011 Zdenek Kalal
%
% This file is part of TLD.
% 
% TLD is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% TLD is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TLD.  If not, see <http://www.gnu.org/licenses/>.

function [bb,conf] = tldExample(opt)

global tld; % holds results and temporal variables

% INITIALIZATION ----------------------------------------------------------

opt.source = tldInitSource(opt.source); % select data source, camera/directory

figure(2); set(2,'KeyPressFcn', @handleKey); % open figure for display of results
finish = 0; 

while 1
    source = tldInitFirstFrame(tld,opt.source,opt.model.min_win, opt.plot.draw_original); % get initial bounding box, return 'empty' if bounding box is too small
    if ~isempty(source), opt.source = source; break; end % check size
end

tld = tldInit(opt,[]); % train initial detector and initialize the 'tld' structure
tld = tldDisplay(0,tld); % initialize display

% RUN-TIME ----------------------------------------------------------------

for i = 2:length(tld.source.idx) % for every frame
    
    tld = tldProcessFrame(tld,i); % process frame i
    tldDisplay(1,tld,i); % display results on frame i
    
    if finish 
        if tld.source.camera
            stoppreview(tld.source.vid);
            closepreview(tld.source.vid);
            close(1);
        end
        if tld.output.video_output.opened
            close(tld.output.video_output.out);
            tld.output.video_output.opened = 0;
        end
%         close(2);

        bb = tld.bb; conf = tld.conf; % return results
        return;
    end
    
    if tld.plot.save == 1
        img = getframe;
        if tld.output.video
            if isempty(tld.output.video_output.out)
                % create a VideoWriter object
                vname = [tld.output.dir 'TLD_result.mp4'];
                sprintf('Recording result to %s', vname)
                tld.output.video_output.out = VideoWriter([tld.output.dir 'TLD_result.mp4'],'MPEG-4');
                tld.output.video_output.out.FrameRate = tld.source.video_handle.FrameRate;
            end
            if tld.output.video_output.opened == 0
                % open a VideoWriter object
                tld.output.video_output.opened = 1;
                open(tld.output.video_output.out);
            end
            writeVideo(tld.output.video_output.out, img); % write a frame
        else
            imwrite(img.cdata,[tld.output.dir num2str(i,'%05d') '.png']);
        end
    else
        if tld.output.video_output.opened == 1
            % close an opened VideoWriter object
            sprintf('Stop recording the video')
            tld.output.video_output.opened = 0;
            close(tld.output.video_output.out);
            tld.output.video_output.out = [];
        end
    end
        
end

bb = tld.bb; conf = tld.conf; % return results

function handleKey(~, evnt)
    switch evnt.Character
        case '1'
            tld.control.maxbbox = 0.2;
            tld.control.update_detector = 0;
        case '2'
            tld.control.maxbbox = 1;
            tld.control.update_detector = 1;
        case '3'
            tld.control.maxbbox = 1;
            tld.control.update_detector = 1;
            tld.model.fliplr = 1;
        case 'c'
            tld.plot.confidence = 1 - tld.plot.confidence;
        case 'q'
            finish = 1;
        case 'd'
            tld.plot.dt =  1 - tld.plot.dt;
        case '#'
            tld.plot.draw = 1 - tld.plot.draw;
        case 'p'
            tld.plot.pex = 1 - tld.plot.pex;
        case 's'
            tld.plot.save = 1 - tld.plot.save;
        case 'n'
            tld.plot.nex = 1 - tld.plot.nex;
        case '-'
            tld.control.maxbbox = tld.control.maxbbox - 0.05;
        case '='
            tld.control.maxbbox = tld.control.maxbbox + 0.05;
        case 't'
            tld.plot.target = 1 - tld.plot.target;
        case 'r'
            tld.plot.replace = 1 - tld.plot.replace;
        case 'f'
            tld.model.fliplr = 1 - tld.model.fliplr;
        case 'o'
            tld.plot.drawoutput = tld.plot.drawoutput + 1;
            if tld.plot.drawoutput > 3
                tld.plot.drawoutput = 0;
            end
        case ' '
            print(gcf,'-r0','-dpng',[tld.name datestr(now,30) '.png']);
        case '.'
            tld.plot.pts = 1 - tld.plot.pts;
        case 'h'
            tld.plot.help = 1 - tld.plot.help;
        case ']'
            tld.control.rescale = tld.control.rescale*1.1;
        case '['
            tld.control.rescale = tld.control.rescale/1.1;
    end
end


end

