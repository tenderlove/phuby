#ifndef PHUBY_RUNTIME
#define PHUBY_RUNTIME

#include <phuby.h>

extern VALUE cPhubyRuntime;

void init_phuby_runtime();
VALUE Phuby_Wrap(zval * value);

#endif
