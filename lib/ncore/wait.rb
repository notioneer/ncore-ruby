module NCore
  module Wait
    extend ActiveSupport::Concern

    private

    def wait_for(seconds, &block)
      return unless seconds
      seconds = 45 if seconds == true
      end_by = seconds.seconds.from_now
      cnt = 0
      until Time.current > end_by
        wait = [end_by-Time.current, retry_in(cnt)].min
        cnt += 1
        sleep wait
        reload
        return self if block.call
      end
      raise self.class.module_parent::WaitTimeout, self
    end

    def retry_in(count)
      (count**1.7).round + 1
    end

  end
end
