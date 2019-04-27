
//------------------------------------------------------------------------------
// GB_AxB:  hard-coded functions for semiring: C<M>=A*B or A'*B
//------------------------------------------------------------------------------

// SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2019, All Rights Reserved.
// http://suitesparse.com   See GraphBLAS/Doc/License.txt for license.

//------------------------------------------------------------------------------

// Unless this file is Generator/GB_AxB.c, do not edit it (auto-generated)

#include "GB.h"
#ifndef GBCOMPACT
#include "GB_AxB__include.h"

// The C=A*B semiring is defined by the following types and operators:

// A*B function (Gustavon):  GB_AgusB__min_rdiv_int32
// A'*B function (dot):      GB_AdotB__min_rdiv_int32
// A*B function (heap):      GB_AheapB__min_rdiv_int32

// C type:   int32_t
// A type:   int32_t
// B type:   int32_t

// Multiply: z = GB_IDIV_SIGNED (bkj, aik, 32)
// Add:      cij = GB_IMIN (cij, x_op_y)
// MultAdd:  int32_t x_op_y = GB_IDIV_SIGNED (bkj, aik, 32) ; cij = GB_IMIN (cij, x_op_y)
// Identity: INT32_MAX
// Terminal: if (cij == INT32_MIN) break ;

#define GB_ATYPE \
    int32_t

#define GB_BTYPE \
    int32_t

#define GB_CTYPE \
    int32_t

// aik = Ax [pA]
#define GB_GETA(aik,Ax,pA) \
    int32_t aik = Ax [pA]

// bkj = Bx [pB]
#define GB_GETB(bkj,Bx,pB) \
    int32_t bkj = Bx [pB]

#define GB_CX(p) Cx [p]

// multiply operator
#define GB_MULT(z, x, y)        \
    z = GB_IDIV_SIGNED (y, x, 32) ;

// multiply-add
#define GB_MULTADD(z, x, y)     \
    int32_t x_op_y = GB_IDIV_SIGNED (y, x, 32) ; z = GB_IMIN (z, x_op_y) ;

// copy scalar
#define GB_COPY(z,x) z = x ;

// monoid identity value (Gustavson's method only, with no mask)
#define GB_IDENTITY \
    INT32_MAX

// break if cij reaches the terminal value (dot product only)
#define GB_DOT_TERMINAL(cij) \
    if (cij == INT32_MIN) break ;

// cij is not a pointer but a scalar; nothing to do
#define GB_CIJ_REACQUIRE(cij,cnz) ;

// declare the cij scalar
#define GB_CIJ_DECLARE(cij) ; \
    int32_t cij ;

// save the value of C(i,j)
#define GB_CIJ_SAVE(cij,p) Cx [p] = cij ;

#define GB_SAUNA_WORK(i) Sauna_Work [i]

//------------------------------------------------------------------------------
// C<M>=A*B and C=A*B: gather/scatter saxpy-based method (Gustavson)
//------------------------------------------------------------------------------

GrB_Info GB_AgusB__min_rdiv_int32
(
    GrB_Matrix C,
    const GrB_Matrix M,
    const GrB_Matrix A, bool A_is_pattern,
    const GrB_Matrix B, bool B_is_pattern,
    GB_Sauna Sauna
)
{ 
    int32_t *restrict Sauna_Work = Sauna->Sauna_Work ;
    int32_t *restrict Cx = C->x ;
    GrB_Info info = GrB_SUCCESS ;
    #include "GB_AxB_Gustavson_meta.c"
    return (info) ;
}

//------------------------------------------------------------------------------
// C<M>=A'*B, C<!M>=A'*B or C=A'*B: dot product
//------------------------------------------------------------------------------

GrB_Info GB_AdotB__min_rdiv_int32
(
    GrB_Matrix *Chandle,
    const GrB_Matrix M, const bool Mask_comp,
    const GrB_Matrix A, bool A_is_pattern,
    const GrB_Matrix B, bool B_is_pattern
)
{ 
    GrB_Matrix C = (*Chandle) ;
    GrB_Info info = GrB_SUCCESS ;
    int nthreads = 1 ;
    #define GB_SINGLE_PHASE
    #include "GB_AxB_dot_meta.c"
    #undef GB_SINGLE_PHASE
    return (info) ;
}

//------------------------------------------------------------------------------
// C<M>=A'*B, C<!M>=A'*B or C=A'*B: dot product (phase 2)
//------------------------------------------------------------------------------

GrB_Info GB_Adot2B__min_rdiv_int32
(
    GrB_Matrix C,
    const GrB_Matrix M, const bool Mask_comp,
    const GrB_Matrix *Aslice, bool A_is_pattern,
    const GrB_Matrix B, bool B_is_pattern,
    int64_t **C_counts,
    int nthreads, int naslice, int nbslice
)
{ 
    #define GB_PHASE_2_OF_2
    #include "GB_AxB_dot2_meta.c"
    #undef GB_PHASE_2_OF_2
    return (GrB_SUCCESS) ;
}

//------------------------------------------------------------------------------
// C<M>=A*B and C=A*B: heap saxpy-based method
//------------------------------------------------------------------------------

#include "GB_heap.h"

GrB_Info GB_AheapB__min_rdiv_int32
(
    GrB_Matrix *Chandle,
    const GrB_Matrix M,
    const GrB_Matrix A, bool A_is_pattern,
    const GrB_Matrix B, bool B_is_pattern,
    int64_t *restrict List,
    GB_pointer_pair *restrict pA_pair,
    GB_Element *restrict Heap,
    const int64_t bjnz_max
)
{ 
    GrB_Matrix C = (*Chandle) ;
    int32_t *restrict Cx = C->x ;
    int32_t cij ;
    int64_t cvlen = C->vlen ;
    GrB_Info info = GrB_SUCCESS ;
    #include "GB_AxB_heap_meta.c"
    return (info) ;
}

#endif
