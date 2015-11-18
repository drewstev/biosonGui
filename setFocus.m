function setFocus(hfig,eventdata,handles) %#ok
gdata=guidata(hfig);

pos = get(gcf, 'Position');  % User might have moved figure.
pointpos = get(0,'pointerlocation');  % Current pointer location.
set(0, 'PointerLocation', [pos(1)+(pos(3)/2),pos(2) + (pos(4)/2)]);
% Now we simulate a mouseclick on the figure using the JAVA.
gdata.ja.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);  % Click down
gdata.ja.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK); % Let up.
set(0,'pointerlocation',pointpos);  % Put the pointer back.
pause(.025)   % drawnow does NOT work here.