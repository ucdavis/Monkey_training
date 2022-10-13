% function checkkeys
[keyIsDown, ~, keyCode]=KbCheck;


if ( keyCode(up)==1)

    stage='pause';


end



if (keyIsDown==1 && keyCode(space))
    disp('reward 4')
    cclabReward(reward, 1, IRI)
end


if (keyIsDown==1 && keyCode(esc))
    stage='trial_end';
end

