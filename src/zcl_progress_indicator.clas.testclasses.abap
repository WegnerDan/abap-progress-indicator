*"* use this source file for your ABAP unit test classes

CLASS ltc_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PUBLIC SECTION.
    METHODS:
      lower_boundary FOR TESTING,
      upper_boundary FOR TESTING,
      between FOR TESTING.
ENDCLASS.


CLASS ltc_test IMPLEMENTATION.
  METHOD lower_boundary.
    DATA(package_size) = zcl_progress_indicator=>determine_package_size( number_of_items = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = package_size ).

    package_size = zcl_progress_indicator=>determine_package_size( number_of_items = 1 ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = package_size ).

    package_size = zcl_progress_indicator=>determine_package_size( number_of_items = 1
                                                                   lower_boundary  = 2 ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = package_size ).
  ENDMETHOD.

  METHOD upper_boundary.
    DATA(package_size) = zcl_progress_indicator=>determine_package_size( number_of_items = 10000000 ).
    cl_abap_unit_assert=>assert_equals( exp = 1000
                                        act = package_size ).

    package_size = zcl_progress_indicator=>determine_package_size( number_of_items = 10000000
                                                                   upper_boundary  = 10000 ).
    cl_abap_unit_assert=>assert_equals( exp = 10000
                                        act = package_size ).
  ENDMETHOD.

  METHOD between.
    DATA(package_size) = zcl_progress_indicator=>determine_package_size( number_of_items = 1000 ).
    cl_abap_unit_assert=>assert_equals( exp = 10
                                        act = package_size ).

    package_size = zcl_progress_indicator=>determine_package_size( number_of_items = 1234 ).
    cl_abap_unit_assert=>assert_equals( exp = 10
                                        act = package_size ).

    package_size = zcl_progress_indicator=>determine_package_size( number_of_items = 1999 ).
    cl_abap_unit_assert=>assert_equals( exp = 10
                                        act = package_size ).

    package_size = zcl_progress_indicator=>determine_package_size( number_of_items = 2000 ).
    cl_abap_unit_assert=>assert_equals( exp = 20
                                        act = package_size ).

    package_size = zcl_progress_indicator=>determine_package_size( number_of_items = 9000 ).
    cl_abap_unit_assert=>assert_equals( exp = 90
                                        act = package_size ).

    package_size = zcl_progress_indicator=>determine_package_size( number_of_items = 10000 ).
    cl_abap_unit_assert=>assert_equals( exp = 100
                                        act = package_size ).

    package_size = zcl_progress_indicator=>determine_package_size( number_of_items = 99999 ).
    cl_abap_unit_assert=>assert_equals( exp = 900
                                        act = package_size ).
  ENDMETHOD.
ENDCLASS.
