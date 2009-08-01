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

static VALUE native_eval(VALUE self, VALUE string, VALUE filename)
{
  zend_first_try {
    zend_eval_string(
      StringValuePtr(string),
      NULL,
      StringValuePtr(filename)
    );
  } zend_end_try();

  return Qnil;
}

void Init_phuby()
{
  mPhuby = rb_define_module("Phuby");

  /* FIXME: This belongs in it's own .c file */
  cPhubyRuntime = rb_define_class_under(mPhuby, "Runtime", rb_cObject);

  rb_define_method(cPhubyRuntime, "start", start, 0);
  rb_define_private_method(cPhubyRuntime, "native_eval", native_eval, 2);
}
