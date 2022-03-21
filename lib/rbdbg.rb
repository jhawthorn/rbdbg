# frozen_string_literal: true

require_relative "rbdbg/version"
require_relative "rbdbg/rbdbg"

module Rbdbg
  class Error < StandardError; end
  # Your code goes here...

  def self.attach_pid(pid)
    Rbdbg.ptrace_attach(pid)
    pid, status = Process.waitpid2(pid)
    unless status.stopped?
      raise "Expected pid #{pid} to stop, but got: #{status.inspect}"
    end
    pid
  end
end
