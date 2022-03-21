# frozen_string_literal: true

require "test_helper"

class TestRbdbg < RbdbgTest
  include Rbdbg

  def test_that_it_has_a_version_number
    refute_nil ::Rbdbg::VERSION
  end

  def test_ptrace_attach
    child_pid = spawn("sleep", "1")
    sleep 0.1

    Rbdbg.ptrace_attach(child_pid)
    pid, status = Process.waitpid2(child_pid)
    assert_equal pid, child_pid
    assert status.stopped?
    refute status.exited?

    # SIGSTOP
    assert_equal 19, status.stopsig, "expected SIGSTOP but got #{status.inspect}"
  end

  def test_attach_pid
    child_pid = spawn("sleep", "1")
    debugee = Rbdbg.attach_pid(child_pid)
    assert debugee
  end

  def test_ptrace_detach
    child_pid = spawn("sleep", "0.5")
    sleep 0.1
    Rbdbg.attach_pid(child_pid)

    Rbdbg.ptrace_detach(child_pid)

    # Wait for proper clean exit
    _, status = Process.waitpid2(child_pid)
    assert status.exited?
    assert status.success?
  end

  def test_registers
    child_pid = spawn("sleep", "1")
    sleep 0.1
    debugee = Rbdbg.attach_pid(child_pid)
    regs = debugee.registers

    # All regs should be filled
    nil_regs = regs.to_h.select { |k, v| v.nil? }
    assert_empty nil_regs, "Expected all regs to have values, missing #{nil_regs.keys.inspect}"
  end

  def test_peek_word
    child_pid = spawn("sleep", "1")
    sleep 0.1
    debugee = Rbdbg.attach_pid(child_pid)

    value = debugee.peek_word(debugee.regs.rsp)
    assert value
  end

  def test_peek_byte
    child_pid = spawn("sleep", "1")
    sleep 0.1
    debugee = Rbdbg.attach_pid(child_pid)

    rsp = debugee.regs.rsp

    word = debugee.peek_word(rsp)

    bytes = [
      debugee.peek_byte(rsp),
      debugee.peek_byte(rsp+1),
      debugee.peek_byte(rsp+2),
      debugee.peek_byte(rsp+3),
      debugee.peek_byte(rsp+4),
      debugee.peek_byte(rsp+5),
      debugee.peek_byte(rsp+6),
      debugee.peek_byte(rsp+7),
    ]

    assert_equal word, bytes.pack("C*").unpack1("Q")
  end
end
