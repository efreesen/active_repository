require 'active_repository'

begin
  require 'active_model'
  require 'active_model/naming'
rescue LoadError
end

begin
  require 'active_hash/base'
  require 'associations/associations'
rescue LoadError
end

require 'active_repository/base'