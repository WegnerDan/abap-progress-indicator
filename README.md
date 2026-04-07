# abap-progress-indicator

This class wraps calls to cl_progress_indicator=>progress_indicate, so that it updates only as often as necessary, but not as rarely as cl_progress_indicator=>progress_indicate with the parameter i_output_immediately = abap_false.

If a non-T100 text is wanted for the progress indicator, instead of calling method indicate, method output_required can be used in combination with the function module `SAPGUI_PROGRESS_INDICATOR` (See example 2). 

Example 1:
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



Example 2:
```abap
DATA(progress_indicator) = zcl_progress_indicator=>create( number_of_items = lines( many_items )
                                                           message_id      = ''
                                                           message_number  = 0 ).

LOOP AT many_items ASSIGNING FIELD-SYMBOL(<item>).
  IF progess_indicator->output_required( processed_items = sy-tabix ).
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = progess_indicator->calc_percentage( sy-tabix ) 
        text       = |Preparing ({ processed_items } of { number_of_items })|.
  ENDIF.
  " do stuff
  " ...
ENDLOOP.
```
