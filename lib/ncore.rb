require 'active_support/all'
require 'active_model'
require 'excon'
require 'pp'

%w(version builder configuration associations attributes client collection exceptions identity lifecycle util base singleton_base).each do |f|
  require "ncore/#{f}"
end

%w(all build count create delete delete_bulk delete_single find find_single update).each do |f|
  require "ncore/methods/#{f}"
end

require 'ncore/rails/action_controller' if defined?(::ActionController)
require 'ncore/rails/active_model'
require 'ncore/rails/module_fix'
