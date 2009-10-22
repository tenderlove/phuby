#include <phuby.h>

zval * Phuby_value_to_zval(VALUE rt, VALUE value)
{
  zval *php_value;

  MAKE_STD_ZVAL(php_value);

  switch(TYPE(value))
  {
    case T_FIXNUM:
      ZVAL_LONG(php_value, NUM2INT(value));
      break;

    case T_TRUE:
    case T_FALSE:
      ZVAL_BOOL(php_value, value == Qtrue ? 1 : 0);
      break;

    case T_FLOAT:
    case T_BIGNUM:
      ZVAL_DOUBLE(php_value, NUM2DBL(value));
      break;

    case T_STRING:
      ZVAL_STRINGL(php_value, StringValuePtr(value), RSTRING_LEN(value), 1);
      break;
    case T_OBJECT:
    case T_DATA:
      {
        object_init_ex(php_value, php_ruby_proxy);
        VALUE map = rb_iv_get(rt, "@proxy_map");
        rb_hash_aset(map, INT2NUM((int)php_value), value);
      }
      break;
    case T_ARRAY:
      {
        array_init(php_value);
        int i;
        for(i = 0; i < RARRAY_LEN(value); i++) {
          VALUE key = rb_funcall(INT2NUM(i), rb_intern("to_s"), 0);
          VALUE thing = RARRAY_PTR(value)[i];
          add_assoc_zval(php_value, StringValuePtr(key), Phuby_value_to_zval(rt, thing));
        }
        VALUE map = rb_iv_get(rt, "@proxy_map");
        rb_hash_aset(map, INT2NUM((int)php_value), value);
      }
      break;
    case T_NIL:
      ZVAL_NULL(php_value);
      break;
    default:
      rb_raise(rb_eRuntimeError, "Can't convert ruby object: %s %d", rb_class2name(CLASS_OF(value)), TYPE(value));
  }

  return php_value;
}

VALUE Phuby_zval_to_value(VALUE rt, zval * value)
{
  switch(Z_TYPE_P(value)) {
    case IS_NULL:
      return Qnil;
      break;
    case IS_BOOL:
      if(Z_BVAL_P(value))
        return Qtrue;
      else
        return Qfalse;
      break;
    case IS_LONG:
      return INT2NUM(Z_LVAL_P(value));
      break;
    case IS_DOUBLE:
      return rb_float_new(Z_DVAL_P(value));
      break;
    case IS_STRING:
      return rb_str_new(Z_STRVAL_P(value), Z_STRLEN_P(value));
      break;
    case IS_ARRAY:
      return Data_Wrap_PhubyArray(rt, value);
      break;
    case IS_OBJECT:
      {
        VALUE map = rb_iv_get(rt, "@proxy_map");
        return rb_hash_aref(map, INT2NUM((int)value));
      }
    default:
      rb_raise(rb_eRuntimeError, "Whoa, I don't know how to convert that");
  }
}

