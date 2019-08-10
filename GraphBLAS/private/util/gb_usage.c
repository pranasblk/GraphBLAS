//------------------------------------------------------------------------------
// gb_usage: check usage and make sure GxB_init has been called
//------------------------------------------------------------------------------

// SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2019, All Rights Reserved.
// http://suitesparse.com   See GraphBLAS/Doc/License.txt for license.

//------------------------------------------------------------------------------

#include "gb_matlab.h"

void gb_usage       // check usage and make sure GxB_init has been called
(
    bool ok,                // if false, then usage is not correct
    const char *message     // error message if usage is not correct
)
{

    //--------------------------------------------------------------------------
    // register the function to clear GraphBLAS
    //--------------------------------------------------------------------------

    mexAtExit (gb_at_exit) ;

    //--------------------------------------------------------------------------
    // make sure GxB_init has been called
    //--------------------------------------------------------------------------

    if (!GB_Global_GrB_init_called_get ( ))
    {

        //----------------------------------------------------------------------
        // initialize GraphBLAS
        //----------------------------------------------------------------------

        OK (GxB_init (GrB_NONBLOCKING, mxMalloc, mxCalloc, mxRealloc, mxFree,
            false)) ;

        //----------------------------------------------------------------------
        // MATLAB matrices are stored by column
        //----------------------------------------------------------------------

        printf ("setting default format: BY COL\n") ;
        OK (GxB_set (GxB_FORMAT, GxB_BY_COL)) ;
    }

    //--------------------------------------------------------------------------
    // check usage
    //--------------------------------------------------------------------------

    if (!ok)
    {
        USAGE (message) ;
    }
}
