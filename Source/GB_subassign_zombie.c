//------------------------------------------------------------------------------
// GB_subassign_zombie: C(I,J)<!,repl> = empty ; using S
//------------------------------------------------------------------------------

// SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2020, All Rights Reserved.
// http://suitesparse.com   See GraphBLAS/Doc/License.txt for license.

//------------------------------------------------------------------------------

// Method 00: C(I,J)<!,repl> = empty ; using S

// M:           NULL
// Mask_comp:   true
// C_replace:   true
// accum:       any (present or not; result is the same)
// A:           any (scalar or matrix; result is the same)
// S:           constructed

#include "GB_subassign_methods.h"

void GB_subassign_zombie
(
    GrB_Matrix C,
    // input:
    const GrB_Index *I,
    const int64_t nI,
    const int Ikind,
    const int64_t Icolon [3],
    const GrB_Index *J,
    const int64_t nJ,
    const int Jkind,
    const int64_t Jcolon [3],
    const GrB_Matrix S,
    GB_Context Context
)
{

    //--------------------------------------------------------------------------
    // get inputs
    //--------------------------------------------------------------------------

    // C and S can be jumbled, but when GB_subref constructs S=C(I,J), it
    // sorts C.  S may be returned as jumbled, however, which is OK here.
    ASSERT (!GB_JUMBLED (C)) ;
    ASSERT (GB_JUMBLED_OK (S)) ;

    ASSERT (!GB_IS_FULL (C)) ;
    int64_t *GB_RESTRICT Ci = C->i ;
    const int64_t *GB_RESTRICT Sx = (int64_t *) S->x ;

    //--------------------------------------------------------------------------
    // Method 00: C(I,J)<!,repl> = empty ; using S
    //--------------------------------------------------------------------------

    // Time: Optimal, O(nnz(S)), assuming S has already been constructed.

    //--------------------------------------------------------------------------
    // Parallel: all entries in S can be processed entirely in parallel.
    //--------------------------------------------------------------------------

    // All entries in C(I,J) are deleted.  The result does not depend on A or
    // the scalar.

    int64_t snz = GB_NNZ (S) ;

    GB_GET_NTHREADS_MAX (nthreads_max, chunk, Context) ;
    int nthreads = GB_nthreads (snz, chunk, nthreads_max) ;

    int64_t nzombies = C->nzombies ;

    int64_t pS ;
    #pragma omp parallel for num_threads(nthreads) schedule(static) \
        reduction(+:nzombies)
    for (pS = 0 ; pS < snz ; pS++)
    { 
        // S (inew,jnew) is a pointer back into C (I(inew), J(jnew))
        int64_t pC = Sx [pS] ;
        int64_t i = Ci [pC] ;       // ok: C is sparse
        // ----[X A 0] or [X . 0]-----------------------------------------------
        // action: ( X ): still a zombie
        // ----[C A 0] or [C . 0]-----------------------------------------------
        // action: C_repl: ( delete ): becomes a zombie
        if (!GB_IS_ZOMBIE (i))
        {
            nzombies++ ;
            Ci [pC] = GB_FLIP (i) ;     // ok: C is sparse
        }
    }

    //--------------------------------------------------------------------------
    // return result
    //--------------------------------------------------------------------------

    C->nzombies = nzombies ;
}
