function gbcovmake
%GBCOVMAKE compile the MATLAB interface for statement coverage testing
%
% See also: gbcover, gbcov_edit

% SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2019, All Rights Reserved.
% http://suitesparse.com   See GraphBLAS/Doc/License.txt for license.

if verLessThan ('matlab', '9.4')
    error ('MATLAB 9.4 (R2018a) or later is required') ;
end

warning ('off', 'MATLAB:MKDIR:DirectoryExists') ;
mkdir ('tmp/@gb/') ;
mkdir ('tmp/@gb/private') ;
mkdir ('tmp/@gb/util') ;
warning ('on', 'MATLAB:MKDIR:DirectoryExists') ;

% copy all m-files into tmp/@gb
mfiles = dir ('../../@gb/*.m') ;
for k = 1:length (mfiles)
    copyfile ([(mfiles (k).folder) '/' (mfiles (k).name)], 'tmp/@gb/') ;
end

% copy all private m-files into tmp/@gb/private
mfiles = dir ('../../@gb/private/*.m') ;
for k = 1:length (mfiles)
    copyfile ([(mfiles (k).folder) '/' (mfiles (k).name)], 'tmp/@gb/private') ;
end

% copy the *.h files
copyfile ('../../@gb/private/util/*.h', 'tmp/@gb/util') ;

% copy and edit the mexfunction/*.c files
cfiles = dir ('../../@gb/private/mexfunctions/*.c') ; 
count = gbcov_edit (cfiles, 0, 'tmp/@gb/private') ;

% copy and edit the util/*.c files
ufiles = [ dir('../../@gb/private/util/*.c') ; dir('*.c') ] ;
count = gbcov_edit (ufiles, count, 'tmp/@gb/util') ;

% create the gbfinish.c file and place in tmp/@gb/util
f = fopen ('tmp/@gb/util/gbcovfinish.c', 'w') ;
fprintf (f, '#include "gb_matlab.h"\n') ;
fprintf (f, 'int64_t gbcov [GBCOV_MAX] ;\n') ;
fprintf (f, 'int gbcov_max = %d ;\n', count) ;
fclose (f) ;

% compile the modified MATLAB interface

% use -R2018a for the new interleaved complex API
flags = '-g -R2018a -DGBCOV' ;

try
    if (strncmp (computer, 'GLNX', 4))
        % remove -ansi from CFLAGS and replace it with -std=c11
        cc = mex.getCompilerConfigurations ('C', 'Selected') ;
        env = cc.Details.SetEnv ;
        c1 = strfind (env, 'CFLAGS=') ;
        q = strfind (env, '"') ;
        q = q (q > c1) ;
        if (~isempty (c1) && length (q) > 1)
            c2 = q (2) ;
            cflags = env (c1:c2) ;  % the CFLAGS="..." string
            ansi = strfind (cflags, '-ansi') ;
            if (~isempty (ansi))
                cflags = [cflags(1:ansi-1) '-std=c11' cflags(ansi+5:end)] ;
                flags = [flags ' ' cflags] ;
                fprintf ('compiling with -std=c11 instead of default -ansi\n') ;
            end
        end
    end
end

libraries = '-L../../../../../../build -L. -L/usr/local/lib -lgraphblas' ;

if (~ismac && isunix)
    flags = [ flags   ' CFLAGS="$CXXFLAGS -fopenmp -fPIC -Wno-pragmas" '] ;
    flags = [ flags ' CXXFLAGS="$CXXFLAGS -fopenmp -fPIC -Wno-pragmas" '] ;
    flags = [ flags  ' LDFLAGS="$LDFLAGS  -fopenmp -fPIC" '] ;
end

inc = ...
'-I. -I../util -I../../../../../../Include -I../../../../../../Source -I../../../../../../Source/Template' ;

here = pwd ;
cd tmp/@gb/private
try

    % compile util files
    cfiles = dir ('../util/*.c') ;

    objlist = '' ;
    for k = 1:length (cfiles)
        % get the full cfile filename
        cfile = [(cfiles (k).folder) '/' (cfiles (k).name)] ;
        % get the object file name
        ofile = cfiles(k).name ;
        objfile = [ ofile(1:end-2) '.o' ] ;
        objlist = [ objlist ' ' objfile ] ;
        % compile the cfile
        mexcmd = sprintf ('mex -c %s -silent %s %s', flags, inc, cfile) ;
        fprintf ('%s\n', cfile) ;
        % fprintf ('%s\n', mexcmd) ;
        eval (mexcmd) ;
    end

    mexfunctions = dir ('*.c') ;

    % compile the mexFunctions
    for k = 1:length (mexfunctions)

        % get the mexFunction filename and modification time
        mexfunc = mexfunctions (k).name ;
        mexfunction = [(mexfunctions (k).folder) '/' mexfunc] ;

        % compile the mexFunction
        mexcmd = sprintf ('mex -silent %s %s %s %s %s', ...
            flags, inc, mexfunction, objlist, libraries) ;
        fprintf ('%s\n', mexfunction) ;
        % fprintf ('%s\n', mexcmd) ;
        eval (mexcmd) ;
    end

catch me
    disp (me.message)
end
cd (here)

