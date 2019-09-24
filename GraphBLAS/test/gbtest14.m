function gbtest14
%GBTEST14 test kron and gb.gbkron

% SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2019, All Rights Reserved.
% http://suitesparse.com   See GraphBLAS/Doc/License.txt for license.

rng ('default') ;
A = sparse (rand (2,3)) ;
B = sparse (rand (4,8)) ;

GA = gb (A) ;
GB = gb (B) ;

C = kron (A,B) ;
G = gb.gbkron ('*', A, B) ;
err = norm (C-G, 1) ;
assert (err < 1e-12)

G = kron (GA, GB) ;
err = norm (C-G, 1) ;
assert (err < 1e-12)

d.kind = 'sparse' ;
d.in0 = 'transpose' ;

G = gb.gbkron ('*', A, B, d) ;
C = kron (A', B) ;
err = norm (C-G, 1) ;
assert (err < 1e-12)
G = kron (GA', GB) ;
err = norm (C-G, 1) ;
assert (err < 1e-12)
d.kind = 'gb' ;
G = gb.gbkron ('*', A, B, d) ;
err = norm (C-G, 1) ;

d2 = d ;
d2.in1 = 'transpose' ;
G = gb.gbkron ('*', A, B, d2) ;
C = kron (A', B') ;
err = norm (C-G, 1) ;
assert (err < 1e-12)
G = kron (GA', GB') ;
err = norm (C-G, 1) ;
assert (err < 1e-12)

E = sparse (rand (8,24)) ;
C = E + kron (A,B) ;
G = gb.gbkron (E, '+', '*', A, B) ;
err = norm (C-G, 1) ;
assert (err < 1e-12)
G = E + kron (GA, GB) ;
err = norm (C-G, 1) ;
assert (err < 1e-12)

[m, n] = size (G) ;
M = logical (sprand (m, n, 0.5)) ;
C = sprand (m, n, 0.5) ;
G = gb (C) ;
T = C + kron (A,B) ;
C (M) = T (M) ;
G = gb.gbkron (G, M, '+', '*', A, B) ;
err = norm (C-G, 1) ;
assert (err < 1e-12)

C = sprand (m, n, 0.5) ;
G = gb (C) ;
T = kron (A,B) ;
C (M) = T (M) ;
G = gb.gbkron (G, M, '*', A, B) ;
err = norm (C-G, 1) ;
assert (err < 1e-12)

fprintf ('gbtest14: all tests passed\n') ;

