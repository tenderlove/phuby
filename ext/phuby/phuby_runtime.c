#include <phuby_runtime.h>

VALUE cPhubyRuntime;

PHP_METHOD(RubyProxy, __call)
{
  char *function;
  int function_len;
  zval *args = NULL;

  if(zend_parse_parameters(ZEND_NUM_ARGS(), "sa|a", &function, &function_len,
        &args) == FAILURE) {
    printf("arg################:\n");
  }

  VALUE rt = rb_funcall(cPhubyRuntime, rb_intern("instance"), 0);
  VALUE map = rb_iv_get(rt, "@proxy_map");
  VALUE obj = rb_hash_aref(map, INT2NUM((int)this_ptr));

  rb_funcall(obj, rb_intern(function), 0);
}

zend_class_entry *php_ruby_proxy;

ZEND_BEGIN_ARG_INFO_EX(arginfo_foo___call, 0, 0, 2)
  ZEND_ARG_INFO(0, function_name)
  ZEND_ARG_INFO(0, arguments)
ZEND_END_ARG_INFO()

function_entry php_ruby_functions[] = {
  PHP_ME(RubyProxy, __call, arginfo_foo___call, 0)
  { NULL, NULL, NULL }
};

static int phuby_ub_write(const char *str, unsigned int strlen)
{
  VALUE self = rb_funcall(cPhubyRuntime, rb_intern("instance"), 0);
  VALUE handler = rb_iv_get(self, "@events");

  rb_funcall(handler, rb_intern("write"), 1, rb_str_new(str, strlen));
  return strlen;
}

static int phuby_header_handler(
    sapi_header_struct *sapi_header,
    sapi_header_op_enum op,
    sapi_headers_struct *sapi_headers)
{
  VALUE header = sapi_header->header ?
    rb_str_new2(sapi_header->header) :
    Qnil;

  VALUE rb_op = Qnil;

  int return_value = 0;

  switch(op) {
    case SAPI_HEADER_DELETE_ALL:
      rb_op = ID2SYM(rb_intern("delete_all"));
      break;
    case SAPI_HEADER_DELETE:
      rb_op = ID2SYM(rb_intern("delete"));
      break;
    case SAPI_HEADER_ADD:
    case SAPI_HEADER_REPLACE:
      rb_op = ID2SYM(rb_intern("store"));
      return_value = SAPI_HEADER_ADD;
      break;
    default:
      rb_raise(rb_eRuntimeError, "header_handler huh?");
  }

  VALUE self = rb_funcall(cPhubyRuntime, rb_intern("instance"), 0);
  VALUE handler = rb_iv_get(self, "@events");

  rb_funcall(handler, rb_intern("header"), 2, header, rb_op);

  return return_value;
}

static int phuby_send_headers(sapi_headers_struct *sapi_headers)
{
  VALUE self = rb_funcall(cPhubyRuntime, rb_intern("instance"), 0);
  VALUE handler = rb_iv_get(self, "@events");

  int rc = sapi_headers->http_response_code == 0 ?
    200 :
    sapi_headers->http_response_code;

  rb_funcall(handler, rb_intern("send_headers"), 1, INT2NUM(rc));

  return SAPI_HEADER_SENT_SUCCESSFULLY;
}

static void phuby_flush(void *server_context)
{
  sapi_send_headers();
}

static VALUE start(VALUE self)
{
  VALUE mutex = rb_iv_get(self, "@mutex");
  rb_funcall(mutex, rb_intern("lock"), 0);

  /* FIXME:
   * I got these from the book.  I don't know wtf they're for yet. */
  int argc = 1;
  char *argv[2] = { "embed4", NULL };
  /* end FIXME */

  php_embed_module.ub_write       = phuby_ub_write;
  php_embed_module.header_handler = phuby_header_handler;
  php_embed_module.send_headers   = phuby_send_headers;
  php_embed_module.flush          = phuby_flush;

  php_embed_init(argc, argv);
  zend_class_entry ce;
  INIT_CLASS_ENTRY(ce, "RubyProxy", php_ruby_functions);

  php_ruby_proxy = zend_register_internal_class(&ce);

  SG(headers_sent) = 0;
  SG(request_info).no_headers = 0;

  return Qnil;
}

static VALUE stop(VALUE self)
{
  php_embed_shutdown();

  VALUE mutex = rb_iv_get(self, "@mutex");
  rb_funcall(mutex, rb_intern("unlock"), 0);

  return Qnil;
}

/* IO reader callback for PHP IO streams */
static size_t rb_io_reader(void *handle, char *buf, size_t len)
{
  VALUE io = (VALUE)handle;
  VALUE string = rb_funcall(io, rb_intern("read"), 1, INT2NUM(len));

  if(Qnil == string) return 0;

  memcpy(buf, StringValuePtr(string), (unsigned int)RSTRING_LEN(string));

  return RSTRING_LEN(string);
}

static size_t rb_io_sizer(void *handle)
{
}

static void rb_io_closer(void *handle)
{
  // We'll let the caller close their own IO
  return;
}

static VALUE native_eval_io(VALUE self, VALUE io, VALUE filename)
{
  zend_file_handle script;

  script.type = ZEND_HANDLE_STREAM;
  script.filename = StringValuePtr(filename);
  script.opened_path = NULL;

  memset(&script.handle.stream.mmap, 0, sizeof(zend_mmap));

  script.handle.stream.handle = (void *)io;
  script.handle.stream.isatty = 0;

  script.handle.stream.reader = rb_io_reader;
  script.handle.stream.fsizer = rb_io_sizer;
  script.handle.stream.closer = rb_io_closer;

  script.free_filename = 0;

  php_execute_script(&script);

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
    return ZVAL2VALUE(self, *value);
  }

  return Qnil;
}

static VALUE set(VALUE self, VALUE key, VALUE value)
{
  zval *php_value = VALUE2ZVAL(self, value);

  ZEND_SET_SYMBOL(EG(active_symbol_table), StringValuePtr(key), php_value);

  return value;
}

void init_phuby_runtime()
{
  cPhubyRuntime = rb_define_class_under(mPhuby, "Runtime", rb_cObject);

  rb_define_method(cPhubyRuntime, "start", start, 0);
  rb_define_method(cPhubyRuntime, "stop", stop, 0);

  rb_define_private_method(cPhubyRuntime, "get", get, 1);
  rb_define_private_method(cPhubyRuntime, "set", set, 2);
  rb_define_private_method(cPhubyRuntime, "native_eval", native_eval, 2);
  rb_define_private_method(cPhubyRuntime, "native_eval_io", native_eval_io, 2);
}
