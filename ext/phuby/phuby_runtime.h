#ifndef PHUBY_RUNTIME
#define PHUBY_RUNTIME

#include <phuby.h>

extern VALUE cPhubyRuntime;
extern zend_class_entry *php_ruby_proxy;

void init_phuby_runtime();

#endif
