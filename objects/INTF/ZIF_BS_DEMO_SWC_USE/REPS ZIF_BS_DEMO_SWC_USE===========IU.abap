INTERFACE zif_bs_demo_swc_use
  PUBLIC.

  TYPES charlike TYPE c LENGTH 25.
  TYPES packed   TYPE p LENGTH 15 DECIMALS 2.

  TYPES: BEGIN OF dummy,
           number    TYPE i,
           char      TYPE charlike,
           string    TYPE string,
           packed    TYPE packed,
           timestamp TYPE utclong,
         END OF dummy.

  TYPES dummys TYPE STANDARD TABLE OF dummy WITH EMPTY KEY.
ENDINTERFACE.