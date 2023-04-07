function [x_eye,y_eye,pause,cool]=checkkeys(keyIsDown,keyCode,pause,cool,x_eye,y_eye,center,x_fp,y_fp)  
    KbName('UnifyKeyNames');    

    esc=KbName('ESCAPE');
    space=KbName('space');
    left=KbName('LeftArrow');
    right=KbName('RightArrow');
    up=KbName('UpArrow');
    down=KbName('DownArrow');
    coolkey=KbName('return');
    
if ( keyCode(left)==1 | keyCode(right)==1 )
                if keyCode(left)==1
                    x_eye=1000;
                    y_eye=1000;
                end
                if keyCode(right)==1
                    x_eye=center(1)+x_fp;
                    y_eye=center(2)-y_fp;
                end
            end
             
            if ( keyCode(up)==1 | keyCode(down)==1 )
                if keyCode(up)==1
                  pause=1;      
                end
                if keyCode(down)==1
                  pause=0;   
                end
            end
            
            if (keyIsDown==1 && keyCode(coolkey))
               if cool==0
%             Eyelink( 'Message', 'coolstart');
            cool=1;
               end
               if cool==1
%             Eyelink( 'Message', 'coolend');
            cool=0;
               end
            end;
            
                  
            if (keyIsDown==1 && keyCode(space))
              giveJuice;  
            end;