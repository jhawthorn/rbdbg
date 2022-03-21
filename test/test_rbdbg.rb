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
    p debugee
  end

  def test_ptrace_detach
    child_pid = spawn("sleep", "1")
    sleep 0.1
    Rbdbg.attach_pid(child_pid)

    Rbdbg.ptrace_detach(child_pid)

    # FIXME
    _, status = Process.waitpid2(child_pid)
    p status
    #assert status.exited?
  end

  def test_registers
    child_pid = spawn("sleep", "1")
    sleep 0.1
    debugee = Rbdbg.attach_pid(child_pid)
    p debugee.registers
  end
end
