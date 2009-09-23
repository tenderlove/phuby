#ifndef PHUBY_CONVERSIONS
#define PHUBY_CONVERSIONS

#include <phuby.h>

VALUE Phuby_zval_to_value(VALUE rt, zval * value);
zval * Phuby_value_to_zval(VALUE rt, VALUE thing);

#define ZVAL2VALUE(rt, a) Phuby_zval_to_value(rt, a)
#define VALUE2ZVAL(rt, a) Phuby_value_to_zval(rt, a)

#endif
