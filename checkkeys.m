% function checkkeys
[keyIsDown, ~, keyCode]=KbCheck;


if ( keyCode(up)==1)

    stage='pause';


end

% if ( keyCode(left)==1 | keyCode(right)==1 )
%     if keyCode(left)==1
%         x_eye=1000;
%         y_eye=1000;
%     end
%     if keyCode(right)==1
%         x_eye=center(1)+x_fp;
%         y_eye=center(2)-y_fp;
%     end
% end

if (keyIsDown==1 && keyCode(space))
    disp('reward 4')
    cclabReward(reward, 1, IRI)
end


if (keyIsDown==1 && keyCode(esc))
    stage='exp_end';
end
if  (keyIsDown==1 && keyCode(left)==1)
    change=true;
end
if  (keyIsDown==1 && keyCode(right)==1)
    change=false;
end


