#include <phuby.h>


VALUE mPhuby;
VALUE cPhubyRuntime;

static VALUE start(VALUE self)
{
  /* FIXME:
   * I got these from the book.  I don't know wtf they're for yet. */
  int argc = 1;
  char *argv[2] = { "embed4", NULL };

  php_embed_init(argc, argv);

  return Qnil;
}

static VALUE stop(VALUE self)
{
  php_embed_shutdown();

  return Qnil;
}

static VALUE native_eval(VALUE self, VALUE string, VALUE filename)
{

  zval return_value;

  zend_first_try {
    zend_eval_string(
      StringValuePtr(string),
      NULL,
      StringValuePtr(filename)
    );
  } zend_end_try();

  return Qnil;
}

static VALUE get(VALUE self, VALUE key)
{
  zval **value;

  if(zend_hash_find(EG(active_symbol_table),
        StringValuePtr(key),
        RSTRING_LEN(key) + 1,
        (void **)&value) == SUCCESS) {

    switch(Z_TYPE_P(*value)) {
      case IS_NULL:
        return Qnil;
        break;
      case IS_BOOL:
        if(Z_BVAL_P(*value))
          return Qtrue;
        else
          return Qfalse;
        break;
      case IS_LONG:
        return INT2NUM(Z_LVAL_P(*value));
        break;
      case IS_DOUBLE:
        return rb_float_new(Z_DVAL_P(*value));
        break;
      case IS_STRING:
        return rb_str_new(Z_STRVAL_P(*value), Z_STRLEN_P(*value));
        break;
      default:
        return Qnil;
    }
  }

  return Qnil;
}

static VALUE set(VALUE self, VALUE key, VALUE value)
{
  zval *php_value;

  MAKE_STD_ZVAL(php_value);
  ZVAL_LONG(php_value, NUM2INT(value));
  ZEND_SET_SYMBOL(EG(active_symbol_table), StringValuePtr(key), php_value);

  return value;
}

void Init_phuby()
{
  mPhuby = rb_define_module("Phuby");

  /* FIXME: This belongs in it's own .c file */
  cPhubyRuntime = rb_define_class_under(mPhuby, "Runtime", rb_cObject);

  rb_define_method(cPhubyRuntime, "start", start, 0);
  rb_define_method(cPhubyRuntime, "stop", stop, 0);
  rb_define_method(cPhubyRuntime, "[]", get, 1);
  rb_define_method(cPhubyRuntime, "[]=", set, 2);

  rb_define_private_method(cPhubyRuntime, "native_eval", native_eval, 2);
}
