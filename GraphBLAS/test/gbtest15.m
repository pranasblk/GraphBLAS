function gbtest15
%GBTEST15 unary operators

% SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2019, All Rights Reserved.
% http://suitesparse.com   See GraphBLAS/Doc/License.txt for license.

types = gbtest_types ;
ops = { 'identity', '~', '-', '1', 'minv', 'abs' }

for k1 = 1:length (ops)
    for k2 = 1:length (types)
        op = [ops{k1} '.' types{k2}] ;
        fprintf ('\nop: %s\n', op) ;
        gb.unopinfo (op) ;
    end
end

fprintf ('gbtest15: all tests passed\n') ;

