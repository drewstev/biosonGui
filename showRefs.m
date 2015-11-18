function showRefs(hfig,evnt); %#ok

try
    open('sir2008-5009.pdf');
catch %#ok
    warndlg('Could not open PDF file. Acrobat installed?')
end