class-pool .
*"* class pool for class ZBP_BC_I_IMPL

*"* local type definitions
include ZBP_BC_I_IMPL=================ccdef.

*"* class ZBP_BC_I_IMPL definition
*"* public declarations
  include ZBP_BC_I_IMPL=================cu.
*"* protected declarations
  include ZBP_BC_I_IMPL=================co.
*"* private declarations
  include ZBP_BC_I_IMPL=================ci.
endclass. "ZBP_BC_I_IMPL definition

*"* macro definitions
include ZBP_BC_I_IMPL=================ccmac.
*"* local class implementation
include ZBP_BC_I_IMPL=================ccimp.

*"* test class
include ZBP_BC_I_IMPL=================ccau.

class ZBP_BC_I_IMPL implementation.
*"* method's implementations
  include methods.
endclass. "ZBP_BC_I_IMPL implementation
