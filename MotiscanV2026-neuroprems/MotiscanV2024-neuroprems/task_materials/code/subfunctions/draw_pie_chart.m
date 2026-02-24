function [] = draw_pie_chart(window,x,y,col,proba)

    % parameters
    [w,h]=Screen('WindowSize',window);
    positionOfMainCircle = [x y x+0.2*h y+0.2*h] ;
    rect_Circle = CenterRectOnPoint(positionOfMainCircle, x ,y );
    startAngle = 0 ;  
    sizeAngle  = round(proba*360); 
    endAngle = 360;
    pensize = 3;
    
    % Draw filled arcs
    if proba==1
        Screen('FillOval',window, col,rect_Circle);
    else
        Screen('FillArc',window, col,rect_Circle,startAngle,sizeAngle);
        Screen('FillArc',window, [255 0 0],rect_Circle,startAngle+sizeAngle,(endAngle-sizeAngle));
    end
    Screen('FrameOval',window,[255 255 255]*0.5,rect_Circle,pensize);


end

