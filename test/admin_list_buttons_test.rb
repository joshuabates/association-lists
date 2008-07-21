require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require 'admin_list'

module AdminListButtonsTestHelper
  def actions
    AdminListButtons::ACTIONS.keys
  end
  
  def stub_model_respond_to(stubbed_actions, bool=true, extra=false)
    @mock_model ||= AdminListModel.new
    
    unless extra
      extra_actions = actions - stubbed_actions
      stub_model_respond_to(extra_actions, !bool, true)
    end
    
    stubbed_actions.each do |act|
      @mock_model.stubs(:respond_to?).with(act).returns bool
      @mock_model.stubs(:respond_to?).with("#{act.to_s}?".to_sym).returns bool
    end
  end
  
  def stub_model_respond_to_true(actions)
    stub_model_respond_to(actions, true)
  end
  
  def stub_model_respond_to_false(actions)
    stub_model_respond_to(actions, false)
  end
  
  
end

class AdminListButtonsTest < Test::Unit::TestCase
  include AdminListButtonsTestHelper
  
  def setup
    @template_mock = stub_everything
    @request_mock = stub_everything
    @request_mock.stubs(:relative_url_root).returns('')
    @template_mock.stubs(:capture => '', :request => @request_mock, :link_to_remote => 'url', :link_to => 'url')
    @mock_model = AdminListModel.new
    @mock_model.stubs(:respond_to?).with(:locked).returns false
    stub_model_respond_to_true(actions)
    @buttons = AdminListButtons.new(@mock_model, @template_mock)
  end
  
  def test_should_show_all_buttons
    actions.each { |action| @buttons.expects(action.to_sym) }
    @buttons.to_s
  end
  
  def test_to_s_should_return_string_with_nil_buttons
    @buttons.stubs(:send).returns nil
    assert_kind_of String, @buttons.to_s
  end
  
  def test_all_buttons_should_show_links
    @buttons.expects(:button).times AdminListButtons::ACTIONS.size
    actions.each { |action| @buttons.send(action) }
  end
  
  def test_all_buttons_should_not_show_links_unless_permitted
    @buttons.expects(:permitted?).times(AdminListButtons::ACTIONS.size).returns(false)
    assert @buttons.to_s.blank?
  end
  
  def test_all_buttons_should_show_links_if_permitted
    @buttons.expects(:permitted?).times(AdminListButtons::ACTIONS.size).returns(true)
    actions.each do |action|
      assert !@buttons.send(action).blank?
    end
  end
  
  def test_should_still_show_edit_button_if_there_are_no_extra_fields
    stub_model_respond_to_false(actions)
    @buttons.expects(:edit).returns ''
    actions.except(:edit).each do |action|
      @button.expects(action).never
    end
    @buttons.to_s
  end
  
  def test_permitted_should_return_true_if_controller_doesnt_respond_to_method
    assert @buttons.permitted?(:test)
  end
  
  def test_permitted_should_return_true_if_controller_grants_permission
    @template_mock.expects(:respond_to?).with(:has_permission_for?).returns(true)
    @template_mock.expects(:has_permission_for?).returns(true)
    assert @buttons.permitted?(:test)
  end
  
  def test_permitted_should_return_false_if_controller_denies_permission
    @template_mock.expects(:respond_to?).with(:has_permission_for?).returns(true)
    @template_mock.expects(:has_permission_for?).returns(false)
    assert !@buttons.permitted?(:test)
  end
  
  def test_boolean_should_check_if_model_attribute_is_a_boolean
    @mock_model.stubs(:respond_to?).with(:test_bool?).returns(true)
    assert @buttons.boolean?(:test_bool)
  end
  
  def test_boolean_should_check_if_model_attribute_is_not_a_boolean
    @mock_model.stubs(:respond_to?).with(:test_bool?).returns(false)
    assert !@buttons.boolean?(:test_bool)
  end
  
  def test_icon_should_return_image_named_after_action_for_non_booleans
    @mock_model.stubs(:respond_to?).with(:edit?).returns(false)
    assert_match(/edit\.gif/, @buttons.icon(:edit))
  end
  
  def test_icon_should_return_image_named_action_off_for_true_booleans
    @mock_model.expects(:published?).returns(true)
    assert_match(/published_off\.gif/, @buttons.icon(:published))
  end
  
  def test_icon_should_return_image_named_action_off_for_true_booleans
    @mock_model.expects(:published?).returns(false)
    assert_match(/published_on\.gif/, @buttons.icon(:published))
  end
  
  def test_action_url_should_call_named_route
    @template_mock.expects(:admin_edit_admin_list_model_url)
    @buttons.action_url(:edit)
  end
  
  def test_action_url_should_build_proper_destroy_url
    @template_mock.expects(:admin_admin_list_model_url)
    @buttons.action_url(:destroy)
  end
  
  def test_action_method_should_return_rest_verb_for_action
    assert_equal :delete, @buttons.action_method(:destroy)
  end
  
  def test_popup_confirmation_returns_text_for_methods_with_delete_verb
    assert_kind_of String, @buttons.popup_confirmation(:destroy)
  end
  
  def test_popup_confirmation_returns_nil_for_non_delete_actions
    assert_nil @buttons.popup_confirmation(:edit)
  end
  
  def test_should_return_ajax_edit_button_for_ajaxed_controller
    @buttons.expects(:link_to_remote)
    @buttons.button(:edit)
  end
  
  def test_should_return_plain_edit_button_when_no_ajax_editing
    @buttons.instance_variable_set("@ajax_edit", false)
    @buttons.expects(:link_to_remote).never
    @buttons.expects(:link_to)
    @buttons.button(:edit)
  end
  
  def test_should_always_return_ajax_buttons_for_everything_other_than_edit
    @buttons.expects(:link_to_remote).times(actions.except(:edit).size)
    actions.except(:edit).each do |action|
      @buttons.button action
    end
  end
  
  def test_locked_should_return_false_if_the_action_is_not_destroy
    assert_equal false, @buttons.locked?(:edit)
  end
  
  def test_locked_should_return_false_if_the_record_lacks_a_locked_field
    assert_equal false, @buttons.locked?(:destroy)
  end
  
  def test_locked_should_return_false_if_the_records_locked_field_is_false
    @mock_model.stubs(:respond_to?).with(:locked).returns true
    @mock_model.stubs(:locked?).returns false
    assert_equal false, @buttons.locked?(:destroy)
  end
  
  def test_locked_should_return_true_if_the_records_locked_field_is_true
    @mock_model.stubs(:respond_to?).with(:locked).returns true
    @mock_model.stubs(:locked?).returns true
    assert_equal true, @buttons.locked?(:destroy)
  end
  
  def test_should_return_locked_image_if_action_is_locked
    @buttons.stubs(:locked?).returns true
    assert_equal @buttons.locked_button, @buttons.button(:destroy)
  end
end