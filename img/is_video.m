function its_video = is_video( path )
    s = regexp(path, '.*\.(mp4|avi|mpeg)');
    its_video = ~isempty(s);
end

