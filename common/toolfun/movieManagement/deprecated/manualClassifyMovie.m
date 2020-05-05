function movieData = manualClassifyMovie(movieData,className,categories,single)
%MANUALCLASSIFYMOVIE allows the user to classify a movie by viewing images from it
%
% movieData = manualClassifyMovie(movieData,className,categories,single)
% 
% This displays several frames from a movie and then allows the user to
% classify the movie as being one of the input categories.
% 
% 
% Input: 
% 
%  movieData - Single movieData structure, or cell array of movieDatas
%  
%  className - A string describing the classification, e.g. "cell type"
%              that the input categories belong to. This allows multiple
%              user-classifications of the same movie
%  
%  categories - A cell array of strings specifying the various categories
%               the user will choos from for the classification.
%  
%  single - If true, a movie can only belong to ONE of the input
%           categories, if false, it can belong to any number.
%
%  Example: You want to go through a set of movies and manually classify
%  whether the cells in the movies are mitotic. You could call the function
%  as follows:
%
%  movieData = manualClassifyMovie(movieData,'cellCycle',{'Interphase','Metaphase','Anaphase','Telophase'},1)
%  
%  
% Output:
% 
%  movieData - The updated movieData(s) with the classification stored in
%              them in a sub-field of the field "classification"
%  
%  
% Hunter Elliott, 10/2009
% 

%% -------- Init --------------- %%

if ~iscell(movieData)
    movieData = {movieData};
    wasSingle = true;
else
    wasSingle = false;
end

nMovies = length(movieData);

if nargin < 3 || isempty(className) || isempty(categories) || isempty(movieData)
   error('Must input a movieData, a class name and a list of categories!!')    
end

if ~ischar(className)
    error('The className must be a character string!')
end

nCat = length(categories);

if ~iscell(categories) || nCat < 2
    error('The categories input must be a cell array of character strings of length >= 2!')
end

if nargin < 4 || isempty(single)
    single=false;
end

if single
    selString = 'single';
else
    selString = 'multiple';
end




%% ------- Display Frames and ask User to Classify Movie -------- %%


figHan = fsFigure(.75);

for j = 1:nMovies
    
    movieData{j} = setupMovieData(movieData{j});

    %Show several frames from the movie
    showMovieTimeline(movieData{j},[],[],figHan);

    %Ask the user to select from the input categories
    [iSelected,OK] = listdlg('ListString',categories,'PromptString',...
        'Select the categories this movie belongs to:',...
        'ListSize',[300,400],'SelectionMode',selString);

        
    if OK == 1
        movieData{j}.classification.(className) = categories(iSelected);            
        updateMovieData(movieData{j});        
    else        
        if ishandle(figHan)
            close(figHan);
        end        
        return
    end   
    
end

if wasSingle
    movieData = movieData{1};
end

if ishandle(figHan)
    close(figHan);
end



