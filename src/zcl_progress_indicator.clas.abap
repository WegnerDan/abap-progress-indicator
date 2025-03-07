CLASS zcl_progress_indicator DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CONSTANTS:
      c_memid_suppress_progress_ind TYPE memoryid VALUE 'SIN'.
    CLASS-METHODS:
      "! create progress indicator object with internally calculated package size<br/><br/>
      "! see method determine_package_size for details about package size<br/><br/>
      "! @parameter number_of_items | number of items that are being processed
      "! @parameter pack_size_min | minimum package size
      "! @parameter pack_size_max | maximum package size
      "! @parameter message_id | id of message that is used for progress output
      "! @parameter message_number | number of message that is used for progress output
      "! <br/>the message must have two message variables<br/>
      "! message variable 1 is filled with the number of processed items<br/>
      "! message variable 2 is filled with the total number of items
      "! @parameter suppress_others | suppress progress indicators issued from outside this class<br/>
      "! this sets parameter id SIN <br/>
      "! restore value of SIN, if follow up steps with progress indicator exist
      "! @parameter run_in_batch | Output messages when running in batch mode
      "! @parameter result | progress indicator object
      create IMPORTING number_of_items TYPE i
                       pack_size_min   TYPE i DEFAULT 1
                       pack_size_max   TYPE i DEFAULT 1000
                       message_id      TYPE sy-msgid
                       message_number  TYPE sy-msgno
                       suppress_others TYPE abap_bool DEFAULT abap_false
                       run_in_batch    TYPE abap_bool DEFAULT abap_false
             RETURNING VALUE(result)   TYPE REF TO zcl_progress_indicator,

      "! create progress indicator object with externally calculated package size<br/><br/>
      "! see method determine_package_size for details about package size<br/><br/>
      "! @parameter number_of_items | number of items that are being processed
      "! @parameter package_size | package size
      "! @parameter message_id | id of message that is used for progress output
      "! @parameter message_number | number of message that is used for progress output
      "! <br/>the message must have two message variables<br/>
      "! message variable 1 is filled with the number of processed items<br/>
      "! message variable 2 is filled with the total number of items
      "! @parameter suppress_others | suppress progress indicators issued from outside this class<br/>
      "! this sets parameter id SIN <br/>
      "! restore value of SIN, if follow up steps with progress indicator exist
      "! @parameter run_in_batch | Output messages when running in batch mode
      "! @parameter result | progress indicator object
      create_with_package_size IMPORTING number_of_items TYPE i
                                         package_size    TYPE i
                                         message_id      TYPE sy-msgid
                                         message_number  TYPE sy-msgno
                                         suppress_others TYPE abap_bool DEFAULT abap_false
                                         run_in_batch    TYPE abap_bool DEFAULT abap_false
                               RETURNING VALUE(result)   TYPE REF TO zcl_progress_indicator,

      "! This method calculates a package size for calling
      "! cl_progress_indicator=>progress_indicate( ) <br/>
      "! The result is a multiple of 10
      "! <br/>
      "!
      "! <h1>Example</h1>
      "! DATA(number_of_items) = lines( materials ).  <br/>
      "! DATA(package_size) =
      "! zcl_progress_indicator=>determine_package_size( number_of_items ). <br/><br/>
      "! LOOP AT materials INTO DATA(material). <br/>
      "! DATA(current_item_number) = sy-tabix. <br/>
      "!   IF current_item_number MOD package_size = 0 <br/>
      "!   OR current_item_number = number_of_items. <br/>
      "!     cl_progress_indicator=>progress_indicate( ) <br/>
      "!   ENDIF. <br/>
      "! " do something that takes a while...   <br/>
      "! ENDLOOP.  <br/>
      "!
      "!
      "! @parameter number_of_items | total number of items
      "! @parameter lower_boundary | minimum result to be returned
      "! @parameter upper_boundary | maximum result to be returned
      "! @parameter result | package size
      determine_package_size IMPORTING number_of_items TYPE i
                                       lower_boundary  TYPE i DEFAULT 1
                                       upper_boundary  TYPE i DEFAULT 1000
                             RETURNING VALUE(result)   TYPE i.

    METHODS:
      "! determine if progress indicator output is required according to package size
      "! @parameter processed_items | number of processed items
      "! @parameter result | abap_true if progress indicator output is required
      output_required IMPORTING processed_items TYPE i
                      RETURNING VALUE(result)   TYPE abap_bool,

      "! indicate progress
      "! @parameter processed_items | number of processed items
      indicate IMPORTING processed_items TYPE i.

  PRIVATE SECTION.
    DATA:
      number_of_items TYPE i,
      package_size    TYPE i,
      message_id      TYPE sy-msgid,
      message_no      TYPE sy-msgno,
      suppress_others TYPE abap_bool,
      run_in_batch    TYPE abap_bool.
ENDCLASS.


CLASS zcl_progress_indicator IMPLEMENTATION.
  METHOD create.
    result = NEW #( ).
    result->message_id      = message_id.
    result->message_no      = message_number.
    result->number_of_items = number_of_items.
    result->suppress_others = suppress_others.
    result->run_in_batch    = run_in_batch.
    result->package_size    = determine_package_size( number_of_items = number_of_items
                                                      lower_boundary  = pack_size_min
                                                      upper_boundary  = pack_size_max ).
  ENDMETHOD.

  METHOD create_with_package_size.
    result = NEW #( ).
    result->message_id      = message_id.
    result->message_no      = message_number.
    result->number_of_items = number_of_items.
    result->package_size    = package_size.
    result->suppress_others = suppress_others.
    result->run_in_batch    = run_in_batch.
  ENDMETHOD.

  METHOD determine_package_size.
    " the progress indicator displays a percentage
    " the goal of this method is to get a package size that roughly represents one percent of the number of items,
    " because updating the progress indicator more often than that does not make sense and can cause performance issues
    DATA(l_number_of_items) = abs( number_of_items ).
    result = l_number_of_items DIV 100.

    " default lower boundary of package size is 1
    " package size 0 does not make sense
    IF result < lower_boundary.
      result = lower_boundary.
      IF result = 0.
        " minimum package size
        result = 1.
      ENDIF.
      RETURN.
    ENDIF.

    " upper boundary of package size is 1000
    " if package size is too high, the progress indicator will seem unresponsive
    IF result > upper_boundary.
      result = upper_boundary.
      RETURN.
    ENDIF.

    " If the result has 2 or more digits, determine the highest place value
    " this determines a multiple of 10 that is as close as possible to a one hundredth of the number of items
    " this makes the progress indicator output a nice multiple of 10 every time it updates
    IF result >= 10.
      DATA(multiplier) = 1.
      WHILE result >= 10.
        result = result DIV 10.
        multiplier *= 10.
      ENDWHILE.
      result *= multiplier.
    ENDIF.
  ENDMETHOD.

  METHOD output_required.
    IF    processed_items MOD package_size = 0
       OR processed_items                  = number_of_items.
      result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD indicate.
    IF     run_in_batch = abap_false
       AND sy-batch     = abap_true.
      RETURN.
    ENDIF.

    IF suppress_others = abap_true.
      SET PARAMETER ID c_memid_suppress_progress_ind FIELD '0'.
    ENDIF.

    IF NOT output_required( processed_items ).
      RETURN.
    ENDIF.

    IF suppress_others = abap_true.
      SET PARAMETER ID c_memid_suppress_progress_ind FIELD '1'.
    ENDIF.

    MESSAGE ID message_id
            TYPE 'S'
            NUMBER message_no
            WITH processed_items number_of_items
            INTO DATA(dummy) ##NEEDED.
    cl_progress_indicator=>progress_indicate( i_msgid              = sy-msgid
                                              i_msgno              = sy-msgno
                                              i_msgv1              = sy-msgv1
                                              i_msgv2              = sy-msgv2
                                              i_msgv3              = sy-msgv3
                                              i_msgv4              = sy-msgv4
                                              i_processed          = processed_items
                                              i_total              = number_of_items
                                              i_output_immediately = abap_true ).

    IF suppress_others = abap_true.
      SET PARAMETER ID c_memid_suppress_progress_ind FIELD '0'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
