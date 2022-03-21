#include <sys/ptrace.h>
#include <errno.h>
#include "rbdbg.h"

VALUE rb_mRbdbg;

static VALUE
ptrace_attach(VALUE _self, VALUE pid) {
    if (ptrace(PTRACE_ATTACH, FIX2INT(pid), NULL, NULL)) {
        rb_syserr_fail(errno, "PTRACE_ATTACH");
    }
    return pid;
}

void
Init_rbdbg(void)
{
  rb_mRbdbg = rb_define_module("Rbdbg");
  rb_define_singleton_method(rb_mRbdbg, "ptrace_attach", ptrace_attach, 1);
}
