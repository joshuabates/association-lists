RAILS_ENV = 'test'

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'ostruct'

begin
  require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
rescue LoadError
  require 'active_support'
  require 'action_controller'
  require 'html/document'
  require 'action_view'
  require 'active_record'
end

require File.expand_path(File.join(File.dirname(__FILE__), '../init.rb'))

class AdminListModel < OpenStruct
  attr_reader :id
  def self.base_class; self end
  def save; @id = 1 end
  def new_record?; @id.nil? end
  def base_class_name; 'admin_list_model' end
  def locked; false end
end

module Admin
  class AdminListModelsController 
    def url_for(*args); 'url' end
    def capture; '' end
    def protect_against_forgery?
      false
    end
  end
end

module ActiveRecord; module Acts; module List; module InstanceMethods
end; end; end; end


class AdminList
  def protect_against_forgery?
    false
  end
end

class Array
  def except(*keys)
    self.reject { |v| keys.include?(v || v.to_s)}
  end
  
  def only(*keys)
    self.reject { |v| !keys.include?(v || v.to_s)}
  end
end