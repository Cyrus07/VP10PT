clear;
restoredefaultpath;

p = mfilename('fullpath');
i = find(p == '\');
cfd = p(1:i(end)-1);

NewPaths{1} = cfd;
NewPaths{2} = fullfile(cfd,'Components');
NewPaths{3} = fullfile(cfd,'Subsystems');
NewPaths{4} = fullfile(cfd,'Projects');
NewPaths{5} = fullfile(cfd,'Global');
NewPaths{6} = fullfile(cfd,'DSP');
NewPaths{7} = fullfile('F:\Lingchen\Work\Codes\VP10PT_v3.4');
NewPaths{8} = fullfile('F:\Lingchen\Work\Codes\VP10PT_v3.4\C');
for n = 1:length(NewPaths)
    addpath(NewPaths{n},path);
end
clear;