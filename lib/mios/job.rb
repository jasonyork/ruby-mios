require 'timeout'

module MiOS
  module Error
    class JobNonexistent < StandardError; end
    class JobError < StandardError; end
    class JobAborted < StandardError; end
    class JobRequeue < StandardError; end
    class JobTimeout < StandardError; end
  end

  class Job
    STATUS = {
      -1 => "Nonexistent",
      0 => "Waiting",
      1 => "In progress",
      2 => "Error",
      3 => "Aborted",
      4 => "Completed",
      5 => "Waiting for callback",
      6 => "Requeue",
      7 => "In progress with pending data"
    }
    attr_reader :id

    def initialize(obj, id, async=false, &block)
      @obj, @id = obj, id
      reload_status!

      if block_given?
        if async
          Thread.new do
            when_complete(&block)
          end
        else
          when_complete(&block)
        end
      end
    end

    def when_complete(&block)
      raise Error::JobTimeout if !exists?
      Timeout::timeout(20) do
        sleep_interval = 0.25

        # If the job is still processing, wait a bit and try again
        while waiting? || in_progress? || waiting_for_callback? || in_progress_with_pending_data? do
          sleep(sleep_interval += 0.25)
          reload_status!
        end
        raise JobError if error?
        raise JobAborted if aborted?
        raise JobRequeue if requeue?
      end
      yield @obj.reload
    rescue Timeout::Error
      $stderr.puts "Timed out waiting for job status to become complete"
      raise Error::JobTimeout
    end

    # Create boolean methods for each status
    STATUS.each do |status_id, method_name|
      define_method("#{method_name.downcase.gsub(' ','_')}?") do
        status == status_id
      end
    end

    def exists?;  not nonexistent?; end

    def status
      @status || reload_status!
    end

    def reload_status!
      @status = @obj.interface.data_request({:id => 'jobstatus', :job => @id, :plugin => 'zwave'})['status']
    end
  end
end