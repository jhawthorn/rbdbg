#include "rbdbg.h"

VALUE rb_mRbdbg;

void
Init_rbdbg(void)
{
  rb_mRbdbg = rb_define_module("Rbdbg");
}
