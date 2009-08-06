#ifndef PHUBY_CONVERSIONS
#define PHUBY_CONVERSIONS

#include <phuby.h>

VALUE Phuby_zval_to_value(zval * value);
zval * Phuby_value_to_zval(VALUE thing);

#define ZVAL2VALUE(a) Phuby_zval_to_value(a)
#define VALUE2ZVAL(a) Phuby_value_to_zval(a)

#endif
