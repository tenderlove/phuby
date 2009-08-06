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

  return INT2NUM(zend_hash_num_elements(Z_ARRVAL_P(array)));
}

static VALUE get(VALUE self, VALUE key)
{
  zval * array;
  zval **value;

  Data_Get_Struct(self, zval, array);

  if(SUCCESS == zend_hash_find(
      Z_ARRVAL_P(array),
      StringValuePtr(key),
      RSTRING_LEN(key) + 1, // Add one for the NULL byte
      (void **)&value
  )) {
    return ZVAL2VALUE(*value);
  }

  return Qnil;
}

static VALUE set(VALUE self, VALUE key, VALUE value)
{
  zval * array;

  Data_Get_Struct(self, zval, array);

  add_assoc_zval(array,
      StringValuePtr(key),
      VALUE2ZVAL(value)
  );

  return self;
}

static VALUE key_eh(VALUE self, VALUE key)
{
  zval * array;
  zval **value;

  Data_Get_Struct(self, zval, array);

  if(zend_hash_exists(Z_ARRVAL_P(array),
        StringValuePtr(key), RSTRING_LEN(key) + 1)) {
    return Qtrue;
  }

  return Qfalse;
}

void init_phuby_array()
{
  cPhubyArray = rb_define_class_under(mPhuby, "Array", rb_cObject);

  rb_define_method(cPhubyArray, "length", length, 0);
  rb_define_method(cPhubyArray, "get", get, 1);
  rb_define_method(cPhubyArray, "set", set, 2);
  rb_define_method(cPhubyArray, "key?", key_eh, 1);
}
