#include <phuby.h>

VALUE mPhuby;

void Init_phuby()
{
  mPhuby = rb_define_module("Phuby");

  init_phuby_runtime();
  init_phuby_array();
}
