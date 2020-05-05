load('C:\Users\Philippe\project-local\externBetzig\analysis\adavid\smallSample\prometaphase\analysis\earlyAndLateML.mat')
ML.sanityCheck;
ML=ML.addAnalysisFolder('C:\Users\Philippe\project-local\externBetzig\analysis\adavid\smallSample\prometaphase\','C:\Users\Philippe\project-local\dataManagement\testPrintMIPArray');
ML.reset()
%%
for i=1:ML.getSize
    ML.getMovie(i).reset();
end

tic;
printMIPArray(ML)
toc;

tic;
printMIPArray(ML)
toc;    