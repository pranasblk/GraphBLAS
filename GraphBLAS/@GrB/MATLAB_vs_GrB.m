% -------------------------------------------------------------------------
% Operations MATLAB matrices vs GraphBLAS matrices
% -------------------------------------------------------------------------
%
% Most of the overloaded operations on GrB matrices work just the same as
% the MATLAB operations of the same name.  There are some important
% differences.  In future versions, the GrB MATLAB interface to
% GraphBLAS may be modified to reduce these differences.
%
% ------------------------------------------------
% Matrix classes and types:
% ------------------------------------------------
%
%     MATLAB supports 3 kinds of sparse matrices: logical, double, and
%     double complex.  For single precision floationg-point (real or
%     complex), and integer matrices, MATLAB only supports dense matrices,
%     not sparse.
%
%     GraphBLAS supports all types:  logical, int8, int16, int32, int64,
%     uint8, uint16, uint32, uint64, single, double, single complex, and
%     double complex.  GraphBLAS has only a single class: the GrB object.
%     It uses a 'type' to represent these different data types.  See help
%     GrB.type for more details.
%
%     'single complex' and 'double complex' matrices were added to
%     GraphBLAS v3.3, as the built-in types GxB_FC32 and GxB_FC64.
%
% ------------------------------------------------
% Explicit zeros:
% ------------------------------------------------
%
%     MATLAB always drops explicit zeros from its sparse matrices.
%     GraphBLAS never drops them, except on request (A = GrB.prune (A)).
%     This difference will always exist between MATLAB abd GraphBLAS.
%
%     GraphBLAS cannot drop zeros automatically, since the explicit zero
%     might be meaningful.  The value zero is the additive identity for
%     the single monoid supported by MATLAB (the '+' of the '+.*'
%     conventional semiring).  MATLAB has only two semirings ('+.*.double'
%     and '+.*.double complex'). GraphBLAS supports both of those, but
%     many more (1000s), many of which have a different identity value.
%     In a shortest-path problem, for example, an edge of weight zero is
%     very different than no edge at all (the identity is inf, for the
%     'min' monoid often used in path problems).
%
% ------------------------------------------------
% MATLAB linear indexing:
% ------------------------------------------------
%
%     In MATLAB, as in A = rand (3) ; X = A (1:6) extracts the first two
%     columns of A as a 6-by-1 vector.  This is not yet supported in
%     GraphBLAS, but may be added in the future.
%
% ------------------------------------------------
% Increasing/decreasing the size of a matrix:
% ------------------------------------------------
%
%     This can be done with a MATLAB matrix, and the result is a sparse
%     10-by-10 sparse matrix A:
%
%         clear A
%         A (1) = sparse (pi)     % A is created as 1-by-1
%         A (10,10) = 42          % A becomes 10-by-10
%         A (5,:) = [ ]           % delete row 5
%
%     The GraphBLAS equivalent does not yet work, since submatrix indexing
%     does not yet increase the size of the matrix:
%
%         clear A
%         A (1) = GrB (pi)            % fails since A does not exist
%         A = GrB (pi)                % works
%         A (10,10) = 42              % fails, since A is 1-by-1
%
%     This feature is not yet supported but may be added in the future.
%
% ------------------------------------------------
% The outputs of min and max, and operations on complex matrices:
% ------------------------------------------------
%
%     MATLAB can compute the min and max on complex values (they return
%     the entry with the largest magnitude).  This is not well-defined
%     mathematically, since the resulting min and max operations cannot be
%     used as monoids, as they can for real types (integer or
%     floating-point types).  As a result, GraphBLAS does not yet support
%     min and max for complex types.
%
%     The 2nd output for [x,i] = min (...) and max do not work in
%     GraphBLAS, and the 'includenan' option is also not available.
%     GraphBLAS uses the 'omitnan' behavior, which is the default in
%     MATLAB.
%
%     These features may be added to GraphBLAS in the future.
%
% ------------------------------------------------
% Singleton expansion:
% ------------------------------------------------
%
%     MATLAB can expand a 'singleton' dimension (of size 1) of one input
%     to match the required size of the other input.  For example, given
%
%         A = rand (4)
%         x = [10 100 1000 10000] 
%
%     these computations both scale the columns of x.  The results are the
%     same:
%
%         A.*x            % singleton expansion
%         A * diag(x)     % standard matrix-vector multiply, which works
%
%     GraphBLAS does not support singleton expansion:
%
%         A = GrB (A)
%         A * diag (x)    % works
%         A.*x            % fails
%
% ------------------------------------------------
% Typecasting from floating-point types to integer:
% ------------------------------------------------
%
%     In MATLAB, the default is to round to the nearest integer.  If the
%     fractional part is exactly 0.5: the integer with larger magnitude is
%     selected.
%
%     In GraphBLAS v3.2.2 and earlier, the convention followed the one in
%     the C API, which is to truncate (the same as what happens in C when
%     typecasting from double to int, for example).
%
%     In GraphBLAS v3.3, the typecasting in the MATLAB interface has been
%     changed to match the MATLAB behavior, when explicitly converting
%     matrices:
%
%       G = 100 * rand (4)
%       G = GrB (G, 'int8')
%
%     If instead, an double matrix is used as-is directly in an integer 
%     semiring, the C typecasting rules are used:
%
%       % suppose A and B are double:
%       A = 5 * rand (4) ;
%       B = 5 * rand (4) ;
%
%       % uses GraphBLAS typecasting
%       C = GrB.mxm (A, '+.*.int8', B)
%
%       % uses MATLAB typecasting:
%       C = GrB.mxm (GrB (A, 'int8'), '+.*.int8', GrB (B, 'int8'))
%
% ------------------------------------------------
% Mixing different integers:
% ------------------------------------------------
%
%     MATLAB refuses to do this.  GraphBLAS can do this, using the rules
%     listed by:
%
%         help GrB.optype
%
% ------------------------------------------------
% Combining 32-bit or lower integers and floating-point:
% ------------------------------------------------
%
%     Both MATLAB and GraphBLAS do the work in floating-point.  In MATLAB,
%     the result is then cast to the integer type.  In GraphBLAS, the GrB
%     matrix has the floating-point type.  MATLAB can only do this if
%     the floating-point operand is a scalar; GraphBLAS can work with any
%     matrices of valid sizes.
%
%     To use the MATLAB rule in GraphBLAS: after computing the result,
%     simply typecast to the desired integer type with
%
%       A = cast (5 * rand (4), 'int8') ;
%       % C is int8:
%       C = A+pi
%       A = GrB (A)
%       % C is double:
%       C = A+pi
%       % C is now int8:
%       C = GrB (C, 'int8')
%
% ------------------------------------------------
% 64-bit integers (int64 and uint64) and double:
% ------------------------------------------------
%
%     In MATLAB, both inputs are converted to 80-bit long double
%     (floating-poing) and then the result is typecasted back to the
%     integer type.  In GraphBLAS the work is done in double, and the
%     result is left in the double type.
%
%     This can be done in MATLAB only if the double operator is a scalar,
%     as in A+pi.  With GraphBLAS, A+B can mix arbitrary types, but A+pi
%     is computed in double, not long double.
%
%     This feature may be added to GraphBLAS in the future, by adding
%     new operators that internally do their work in long double.
%
% ------------------------------------------------
% MATLAB integer operations saturate:
% ------------------------------------------------
%
%     If a = uint8 (255), and b = uint8 (1), then a+b for MATLAB matrices
%     is 255.  That is, the results saturate on overflow or underflow, to
%     the largest and smallest integer respectively.
%
%     This kind of arithmetic is not compatible with integer semirings,
%     and thus MATLAB does not support integer matrix computations such as
%     C=A*B.
%
%     GraphBLAS supports integer semirings, and to do so in requires
%     integer operations that act in a modulo fashion.  As a result if
%     a=GrB(255,'uint8') and b=GrB(1,'uint8'), then a+b is zero.
%
%     It would be possible to add saturating binary operators to replicate
%     the saturating integer behavior in MATLAB, since this is useful for
%     operations such as A+B or A.*B for signals and images.  This may be
%     added in the future, as C = GrB.eadd (A, '+saturate', B) for
%     example.
%
%     This affects the following operators and functions, and likely more
%     as well:
%
%         +   plus
%         -   minus
%         -   uminus (as in C = -A)
%         .*  times
%         ./  ldivide
%         .\  rdivide
%         .^  power
%
%         sum, prod:  MATLAB converts to double; GraphBLAS keeps the type
%         of the input
%
%     It does not affect the following:
%
%         +   uplus (nothing to do)
%         *   mtimes (GraphBLAS can do this, MATLAB can't)
%         <   lt
%         <=  le
%         >   gt
%         >=  ge
%         ==  eq
%         ~=  ne
%             bitor, bitand, ...
%         ~   logical negation
%         |   or
%         &   and
%         '   ctranspose
%         .'  transpose
%             subsref
%             subsasgn
%             end
%
% ------------------------------------------------
% The rules for concatenation differ.
% ------------------------------------------------
%
%     In MATLAB, C = [A1 A2 A3 ...] results in a matrix C whose type
%     depends on all the types in the list.  In GraphBLAS, C has the same
%     type as A1.
%
% ------------------------------------------------
% Bitwise operators:
% ------------------------------------------------
%
%     These were not available in GraphBLAS v3.2, but appear as new
%     additions to GraphBLAS v3.3.  They work just the same in GraphBLAS
%     as they do in MATLAB, except that GraphBLAS can use the bitwise
%     operations in semirings; for example, if A and B are uint8, then:
%
%         C = GrB.mxm (A, 'bitor.bitand', B) ;
%
%     computes C = A*B using the 'bitor.bitand.uint8' semiring.  Try:
%
%         GrB.semiringinfo ('bitor.bitand.uint8')
%
% For more details, see the GraphBLAS user guide in GraphBLAS/Doc.
%
% See also GrB, sparse.

% SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2020, All Rights
% Reserved. http://suitesparse.com.  See GraphBLAS/Doc/License.txt.

help GrB.MATLAB_vs_GrB ;
