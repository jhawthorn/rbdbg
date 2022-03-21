# frozen_string_literal: true

require "test_helper"

class TestRbdbg < RbdbgTest
  def test_that_it_has_a_version_number
    refute_nil ::Rbdbg::VERSION
  end

  def test_ptrace_attach
    child_pid = spawn("sleep 2")
    Rbdbg.ptrace_attach(child_pid)
    pid, status = Process.waitpid2(child_pid)
    assert_equal pid, child_pid
    assert status.stopped?
    refute status.exited?

    # SIGTRAP
    #assert_equal 5, status.stopsig, "expected SIGTRAP but got #{status.inspect}"
  end

  def test_attach_pid
    child_pid = spawn("sleep 2")
    Rbdbg.attach_pid(child_pid)
  end
end
