function [unzipFilename]=unzipTiff(filename,outputDir)
system(sprintf('bunzip2 "%s"',filename));
[p,n,e]=fileparts(filename);
unzipFilename=[p filesep n];
movefile(unzipFilename,outputDir);
