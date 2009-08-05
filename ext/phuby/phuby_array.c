#include <phuby.h>

VALUE cPhubyArray;

VALUE Data_Wrap_PhubyArray(zval * value)
{
  return Data_Wrap_Struct(cPhubyArray, 0, 0, value);
}

static VALUE length(VALUE self)
{
  zval * array;

  Data_Get_Struct(self, zval, array);

  return INT2NUM(array->value.ht->nNumOfElements);
}

void init_phuby_array()
{
  cPhubyArray = rb_define_class_under(mPhuby, "Array", rb_cObject);

  rb_define_method(cPhubyArray, "length", length, 0);
}
