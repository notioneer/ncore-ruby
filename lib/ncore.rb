require 'active_support/all'
require 'excon'
require 'multi_json'
require 'pp'

%w(version builder configuration associations attributes client collection exceptions identity lifecycle util base singleton_base).each do |f|
  require "ncore/#{f}"
end

%w(all build count create delete delete_single find find_single update).each do |f|
  require "ncore/methods/#{f}"
end

require 'ncore/rails/active_model' if defined?(::ActiveModel)
