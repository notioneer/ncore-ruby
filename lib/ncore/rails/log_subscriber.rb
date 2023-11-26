module NCore
  module LogSubscriber
    extend ActiveSupport::Concern

    included do
      class_attribute :runtime_variable, instance_accessor: false

      # make :request show up in parent::LogSubscriber.new.public_methods(false)
      define_method :request do |event|
        log_request event
      end
    end

    module ClassMethods
      def runtime=(value)
        Thread.current[runtime_variable] = value
      end

      def runtime
        Thread.current[runtime_variable] ||= 0
      end

      def reset_runtime
        rt, self.runtime = runtime, 0
        rt
      end
    end

    DEBUG_STATUSES = (200..299).to_a + [404, 409, 422]

    def log_request(event)
      self.class.runtime += event.duration

      env = event.payload
      url = env[:url].to_s
      http_method = env[:method].to_s.upcase
      http_status = env[:status] || -1

      msg = "%s %s" % [http_method, url]
      res = " -> %d (%.1f ms)" % [http_status, event.duration]

      msg = color(msg, :yellow)
        # for rails≤70, must exclude :bold param entirely since a Hash is truthy
      if (200..299).include? http_status
        res = color(res, :green, bold: true)
      else
        res = color(res, :red, bold: true)
      end

      if DEBUG_STATUSES.include? http_status
        debug "  #{msg}"
        debug "  #{res}"
      else
        error "  #{msg}"
        error "  #{res}"
      end
    end

  end

  # Extends ActionController's logging system so as to include Api
  #   cumulative runtime at the end of each action's log entry.
  # See ActiveRecord::Railties::ControllerRuntime for reference
  module ControllerRuntime
    extend ActiveSupport::Concern

    protected

    mattr_accessor :api_runtime_list
    self.api_runtime_list = []

    def process_action(action, *args)
      api_runtime_list.each do |arl|
        arl[:log_sub].reset_runtime
        arl[:rt] = 0
      end
      super
    end

    def cleanup_view_runtime
      rt_before_render = {}
      rt_after_render = {}
      api_runtime_list.each do |arl|
        rt_before_render[arl[:title]] = arl[:log_sub].reset_runtime
      end
      runtime = super
      api_runtime_list.each do |arl|
        rt_after_render[arl[:title]] = arl[:log_sub].reset_runtime
        arl[:rt] = rt_before_render[arl[:title]] + rt_after_render[arl[:title]]
      end
      runtime - rt_after_render.values.sum
    end

    def append_info_to_payload(payload)
      super
      payload[:api_runtime] = {}
      api_runtime_list.each do |arl|
        payload[:api_runtime][arl[:title]] = arl[:rt] + arl[:log_sub].reset_runtime
      end
    end


    module ClassMethods

      def log_process_action(payload)
        messages, rt_set = super, payload[:api_runtime]
        rt_set.each do |title, rt|
          messages << ("#{title}: %.1fms" % rt.to_f) if rt && rt > 0
        end if rt_set
        messages
      end

      def register_api_runtime(log_sub, title)
        unless ControllerRuntime.api_runtime_list.detect{|arl| arl[:log_sub]==log_sub }
          ControllerRuntime.api_runtime_list += [{log_sub: log_sub, title: title, rt: 0}]
        end
      end
    end

  end
end
