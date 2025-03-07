# abap-progress-indicator

This class wraps calls to cl_progress_indicator=>progress_indicate, so that it updates only as often as necessary, but not as rarely as cl_progress_indicator=>progress_indicate with the parameter i_output_immediately = abap_false.

Example:
```abap
" message needs to have two variables
" var1: number of processed items
" var2: total number of items
IF 0 = 1. MESSAGE s001(SOME_MSG_CLS) WITH 0 0. ENDIF. " for where used list
DATA(progress_indicator) = zcl_progress_indicator=>create( number_of_items = lines( many_items )
                                                           message_id      = 'SOME_MSG_CLS'
                                                           message_number  = '001' ).

LOOP AT many_items ASSIGNING FIELD-SYMBOL(<item>).
  progress_indicator->indicate( processed_items = sy-tabix ).
  " do stuff
  " ...
ENDLOOP.
```
