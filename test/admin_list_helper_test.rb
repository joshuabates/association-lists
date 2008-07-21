require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require 'admin_list_helper'

class AdminListHelperTest < Test::Unit::TestCase
  include AdminListHelper
  
  def setup
    @admin_list_stub = stub(:to_list => '')
  end
  
  def test_admin_list_should_create_a_new_admin_list
    AdminList.expects(:new).returns(@admin_list_stub)
    admin_list :test
  end
  
  def test_admin_list_should_call_to_list_on_admin_list
    @admin_list_stub.expects(:to_list)
    AdminList.stubs(:new).returns(@admin_list_stub)
    admin_list :test
  end
end