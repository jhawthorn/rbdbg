# frozen_string_literal: true

require_relative "rbdbg/version"
require_relative "rbdbg/rbdbg"

module Rbdbg
  class Error < StandardError; end
  # Your code goes here...

  module Regs
    X86_64_NAMES = %i[
      r15 r14 r13 r12 rbp rbx r11 r10 r9 r8 rax rcx rdx rsi rdi orig_rax rip cs
      eflags rsp ss fs_base gs_base ds es fs gs
    ]
    X86_64 = Struct.new(*X86_64_NAMES) do
      def inspect
        <<~STR
          #<Regs::X86_64
            rax     0x#{rax.to_s 16}
            rbx     0x#{rbx.to_s 16}
            rcx     0x#{rcx.to_s 16}
            rdx     0x#{rdx.to_s 16}
            rsi     0x#{rsi.to_s 16}
            rdi     0x#{rdi.to_s 16}
            rbp     0x#{rbp.to_s 16}
            rsp     0x#{rsp.to_s 16}
            r8      0x#{r8.to_s 16}
            r9      0x#{r9.to_s 16}
            r10     0x#{r10.to_s 16}
            r11     0x#{r11.to_s 16}
            r12     0x#{r12.to_s 16}
            r13     0x#{r13.to_s 16}
            r14     0x#{r14.to_s 16}
            r15     0x#{r15.to_s 16}
            rip     0x#{rip.to_s 16}
            eflags  0x#{eflags.to_s 16}
            cs      0x#{cs.to_s 16}
            ss      0x#{ss.to_s 16}
            ds      0x#{ds.to_s 16}
            es      0x#{es.to_s 16}
            fs      0x#{fs.to_s 16}
            gs      0x#{gs.to_s 16}
          >
        STR
      end
    end
  end

  class AddressSpace
    def initialize(debugee)
      @debugee = debugee
      @pid = debugee.pid
    end

    def read(address, bytesize)
      File.open("/proc/#{@pid}/mem", "rb") do |f|
        f.seek address
        f.read bytesize
      end
    end
  end

  class Debugee
    attr_reader :pid

    def initialize(pid)
      @pid = pid
    end

    def registers
      regs = Rbdbg.ptrace_getregset(@pid)
      Regs::X86_64.new(*regs)
    end
    alias regs registers

    def peek_word(addr)
      Rbdbg.ptrace_peektext(@pid, addr)
    end

    def peek_byte(addr)
      addr_offset = addr & 7
      addr_base = addr - addr_offset
      word = Rbdbg.ptrace_peektext(@pid, addr_base)
      (word >> (addr_offset * 8)) & 0xff
    end

    def mem
      AddressSpace.new(self)
    end
  end

  def self.attach_pid(pid)
    Rbdbg.ptrace_attach(pid)
    pid, status = Process.waitpid2(pid)
    unless status.stopped?
      raise "Expected pid #{pid} to stop, but got: #{status.inspect}"
    end
    Debugee.new(pid)
  end
end
