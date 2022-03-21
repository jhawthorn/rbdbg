#include <sys/ptrace.h>
#include <sys/uio.h>
#include <linux/elf.h>
#include <errno.h>
#include "rbdbg.h"


VALUE rb_mRbdbg;

static long
rb_ptrace_safe(const char *request_name, int request, pid_t pid, void *addr, void *data) {
    errno = 0;
    long result = ptrace(request, pid, addr, data);
    if (errno != 0) {
        rb_syserr_fail(errno, request_name);
    }
    return result;
}

#define PTRACE_SAFE(request, pid, addr, data) rb_ptrace_safe(#request, (request), (pid), (addr), (data))

static VALUE
ptrace_attach(VALUE _self, VALUE pid) {
    PTRACE_SAFE(PTRACE_ATTACH, NUM2PIDT(pid), 0L, 0L);
    return pid;
}

static VALUE
ptrace_cont(VALUE _self, VALUE pid) {
    PTRACE_SAFE(PTRACE_CONT, NUM2PIDT(pid), 0L, 0L);
    return pid;
}

static VALUE
ptrace_detach(VALUE _self, VALUE pid) {
    PTRACE_SAFE(PTRACE_DETACH, NUM2PIDT(pid), 0L, 0L);
    return pid;
}

static VALUE
ptrace_getregset(VALUE _self, VALUE pid) {
    long buf[128];
    int reg_size = sizeof(buf[0]);
    struct iovec regs = {
        .iov_base = &buf,
        .iov_len = sizeof(buf)
    };
    PTRACE_SAFE(PTRACE_GETREGSET, NUM2PIDT(pid), (void *)NT_PRSTATUS, &regs);
    VALUE arr = rb_ary_new_capa(regs.iov_len / reg_size);
    for (size_t i = 0; i < regs.iov_len / reg_size; i++) {
        VALUE val = ULONG2NUM(buf[i]);
        rb_ary_push(arr, val);
    }
    return arr;
}

void
Init_rbdbg(void)
{
  rb_mRbdbg = rb_define_module("Rbdbg");
  rb_define_singleton_method(rb_mRbdbg, "ptrace_attach", ptrace_attach, 1);
  rb_define_singleton_method(rb_mRbdbg, "ptrace_cont", ptrace_cont, 1);
  rb_define_singleton_method(rb_mRbdbg, "ptrace_detach", ptrace_detach, 1);
  rb_define_singleton_method(rb_mRbdbg, "ptrace_getregset", ptrace_getregset, 1);
}
