//------------------------------------------------------------------------------
// gb_string_to_binop: get a GraphBLAS operator from a string
//------------------------------------------------------------------------------

// SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2019, All Rights Reserved.
// http://suitesparse.com   See GraphBLAS/Doc/License.txt for license.

//------------------------------------------------------------------------------

#include "gb_matlab.h"

// The string has the form op_name.op_type.  For example '+.double' is the
// GrB_PLUS_FP64 operator.  The type is optional.  If not present, it defaults
// to the default_type parameter.

// type: a MATLAB string defining one of 12 operator types:
//  'logical', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64',
//  'uint64', 'single', 'double', 'complex' (TODO: complex)

GrB_BinaryOp gb_string_to_binop         // return binary operator from a string
(
    char *opstring,                     // string defining the operator
    const GrB_Type default_type         // default type if not in the string
)
{

    //--------------------------------------------------------------------------
    // check inputs
    //--------------------------------------------------------------------------

    if (opstring == NULL || opstring [0] == '\0')
    {
        // no operator is present, or present and empty; this is not yet an
        // error, since many uses of GraphBLAS functions use an optional accum
        // operator.
        return (NULL) ;
    }

    //--------------------------------------------------------------------------
    // get the string and parse it
    //--------------------------------------------------------------------------

    int32_t position [2] ;
    gb_find_dot (position, opstring) ;

    char *op_name = opstring ;
    char *op_typename = NULL ;
    if (position [0] >= 0)
    {
        opstring [position [0]] = '\0' ;
        op_typename = opstring + position [0] + 1 ;
    }

    //--------------------------------------------------------------------------
    // get the operator type
    //--------------------------------------------------------------------------

    GrB_Type type ;
    if (op_typename == NULL)
    {
        type = default_type ;
    }
    else
    {
        type = gb_string_to_type (op_typename) ;
    }

    //--------------------------------------------------------------------------
    // convert the string to a GraphBLAS binary operator, built-in or Complex
    //--------------------------------------------------------------------------

    return (gb_string_and_type_to_binop (op_name, type)) ;
}
