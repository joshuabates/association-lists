require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require 'admin_list'

class AdminListsTest < Test::Unit::TestCase
  include ActionView::Helpers::RecordIdentificationHelper
  
  def setup
    @mock_model = AdminListModel.new(:title => 'model name')
    @mock_models = [@mock_model]
    @template_mock = Admin::AdminListModelsController.new
    @template_mock.stubs(:instance_variable_get).returns @mock_models
    @admin_list = AdminList.new(:admin_list_model, @template_mock, {})
    AdminListButtons.any_instance.stubs(:to_s).returns("buttons")
  end
  
  def test_id_should_return_string
    assert_kind_of(String, @admin_list.id)
  end
  
  def test_new_admin_list_should_get_model_list_from_template
    @template_mock.expects(:instance_variable_get).returns(@mock_models)
    AdminList.new(:admin_list_model, @template_mock, {})
  end
  
  def test_to_list_should_return_string
    assert_kind_of String, @admin_list.to_list
  end
  
  def test_list_should_return_ul_tag
    assert @admin_list.list =~ /\<ul.*id=\"admin_list_models\"/
  end
  
  def test_list_should_call_li_tag_for_each_record
    AdminList.any_instance.expects(:li_tag).times(@mock_models.size)
    @admin_list = AdminList.new(:admin_list_model, @template_mock, {}).list
  end
  
  def test_should_return_empty_ul_tag_when_no_models
    @template_mock.stubs(:instance_variable_get).returns([])
    admin_list = AdminList.new(:admin_list_model, @template_mock, {})
    assert admin_list.list =~ /\<ul.*\/ul\>/
  end
  
  def test_sortable_javascript_should_return_nil_if_the_model_isnt_sortable
    @admin_list.expects(:sortable?).returns(false)
    assert_nil @admin_list.sortable_javascript
  end
  
  def test_sortable_javascript_should_return_string_if_the_model_is_sortable
    @template_mock.stubs(:admin_sort_admin_list_models_url).returns 'url'
    @admin_list.expects(:sortable?).returns(true)
    assert_kind_of String, @admin_list.sortable_javascript
  end
  
  def test_sortable_javascript_should_call_restfull_sort_url
    @template_mock.expects(:admin_sort_admin_list_models_url).returns 'url'
    @admin_list.expects(:sortable?).returns(true)
    assert_kind_of String, @admin_list.sortable_javascript
  end
  
  def test_sortable_should_check_if_the_model_acts_as_a_list
    im_mock = mock
    im_mock.expects(:include?).with(ActiveRecord::Acts::List::InstanceMethods)
    @mock_model.class.stubs(:included_modules).returns im_mock
    @admin_list.sortable?
  end
  
  def test_li_tag_should_be_an_li_tag
    li_tag = @admin_list.li_tag(@mock_models.first)
    assert li_tag =~ /^\<li/
  end
  
  def test_li_tag_should_have_title_and_buttons
    @admin_list.expects(:title_and_buttons).returns('')
    li_tag = @admin_list.li_tag(@mock_models.first)
  end
  
  def test_li_tag_should_have_ajax_editor_box
    @admin_list.expects(:ajax_editor_box).returns('')
    li_tag = @admin_list.li_tag(@mock_models.first)
  end
  
  def test_ajax_editor_box_should_be_a_div_tag
    @admin_list.stubs(:ajax_edit?).returns true
    @admin_list.stubs(:ajax_edit_box_closer).returns ''
    assert_match( /div.*#{dom_id(@mock_model, 'edit_box')}/, @admin_list.ajax_editor_box(@mock_model) )
  end
  
  def test_ajax_editor_box_should_have_a_closer
    @admin_list.stubs(:ajax_edit?).returns true
    @admin_list.expects(:ajax_edit_box_closer).returns ''
    @admin_list.ajax_editor_box @mock_model
  end
  
  def test_ajax_editor_box_should_have_an_editor
    @admin_list.stubs(:ajax_edit?).returns true
    @admin_list.stubs(:ajax_edit_box_closer).returns ''
    assert_match( /div.*#{dom_id(@mock_model, 'editor')}/, @admin_list.ajax_editor_box(@mock_model) )
  end
  
  def test_ajax_edit_box_closer_should_be_a_div_tag
    assert_match( /div.*#{dom_id(@mock_model, 'edit_box_closer')}/, @admin_list.ajax_edit_box_closer(@mock_model) )
  end
  
  def test_ajax_edit_box_closer_should_be_a_link_to_close_edit_box
    assert_match( /\<a/, @admin_list.ajax_edit_box_closer(@mock_model) )
  end
  
  def test_title_and_buttons_should_be_in_a_div_tag_with_dom_id
    assert @admin_list.title_and_buttons(@mock_models.first) =~ /^\<div .*#{dom_id(@mock_models.first, 'title_and_buttons')}/
  end
  
  def test_title_and_buttons_should_have_title
    assert @admin_list.title_and_buttons(@mock_models.first) =~ /#{@mock_model.title}/
  end
  
  def test_in_resource_chain_should_check_if_resource
    @mock_model.expects(:respond_to?).with(:resource_chain)
    @admin_list.in_resource_chain?
  end
  
  def test_resource_chain_url_param_should_return_first_in_resource_chain
    @mock_model.stubs(:resource_chain).returns(["one"])
    assert_equal "one", @admin_list.resource_chain_url_param
  end
  
end