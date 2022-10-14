function [pix] = deg2pix(xy, cfg)
%deg2pix Convert the values in xy from degrees to pixels.
%   If vector with two columns, convert first column as x coord, second as
%   y coord. In all other cases, convert everything as if an x coord.

if ndims(xy)==2 && size(xy, 1)==2
    pix = vertcat(xy(1, :) * cfg.ppdX, xy(2, :) * cfg.ppdY);
elseif ndims(xy)==2 && size(xy, 2)==2
    pix = vertcat(xy(:, 1) * cfg.ppdX, xy(:, 2) * cfg.ppdY);
else
    pix = xy * cfg.ppdX;
end

