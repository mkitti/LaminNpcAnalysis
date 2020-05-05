function mkdirRobust(path)
  if(~isdir(path))
    if (~strcmp(computer('arch'), 'win64'))
        system(['mkdir -p "' path '"']);
    else
        system(['mkdir "' path '"']);
        mkdir(path);
    end
  end 
