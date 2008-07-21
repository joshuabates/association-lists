RAILS_ENV = 'test'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'test/unit'
require 'mocha'
require 'ostruct'

class AdminListModel < OpenStruct
  attr_reader :id
  def self.base_class; self end
  def save; @id = 1 end
  def new_record?; @id.nil? end
  def base_class_name; 'admin_list_model' end
  def locked; false end
end

class Admin::AdminListModelsController 
  def url_for(*args); 'url' end
  def capture; '' end
end

class Array
  def except(*keys)
    self.reject { |v| keys.include?(v || v.to_s)}
  end
  
  def only(*keys)
    self.reject { |v| !keys.include?(v || v.to_s)}
  end
end