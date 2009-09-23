#ifndef PHUBY_ARRAY
#define PHUBY_ARRAY

extern VALUE cPhubyArray;

void init_phuby_array();
VALUE Data_Wrap_PhubyArray(VALUE rt, zval * value);

#endif
