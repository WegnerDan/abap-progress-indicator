# abap-progress-indicator

This class wraps calls to cl_progress_indicator=>progress_indicate, so that it updates only as often as necessary, but not as rarely as cl_progress_indicator=>progress_indicate with the parameter i_output_immediately = abap_false.
