class AdminList
  include ActionView::Helpers::JavascriptHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::RecordIdentificationHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::TagHelper
  
  attr_reader :controller
  delegate :capture, :to => :controller
  delegate :url_for, :to => :controller
  
  def initialize(model_name, controller, options)
    @model_name, @controller, @options = model_name.to_s, controller, options
    @model_list = @controller.instance_variable_get("@#{@model_name.to_s.underscore.pluralize}")
    @model_list = [] unless @model_list.is_a? Array
    @model_klass = @model_name.to_s.classify.constantize
  end
  
  def id
    ActionController::RecordIdentifier.plural_class_name(@model_klass)
  end
  
  def to_list
    [ list, sortable_javascript ].compact.join("\n")
  end
  
  def list
    content_tag :ul, :id => id, :class => "admin_list" do
      @model_list.map { |m| li_tag(m) }.join("\n")
    end
  end
  
  def sortable_javascript
    return unless sortable?
    sortable_element id, :url => sortable_url, :handle => "title_and_buttons"
  end
  
  def sortable_class
    "draggable" if sortable?
  end
  
  def sortable?
    @sortable unless @sortable.nil?
    @sortable = @model_klass.included_modules.include? ActiveRecord::Acts::List::InstanceMethods
  end
  
  def sortable_url
    url_params = ["admin_sort_#{@model_name.pluralize.downcase}_url"]
    url_params << resource_chain_url_param if in_resource_chain?
    controller.send(*url_params.compact)
  end
  
  def in_resource_chain?
     @model_list.first.respond_to? :resource_chain
  end
  
  def resource_chain_url_param
    @model_list.first.resource_chain[0]
  end
  
  def li_tag(record)
    content_tag :li, :id => dom_id(record, 'row'), :class => "#{sortable_class}" do
      title_and_buttons(record) + ajax_editor_box(record)
    end
  end
  
  def title_and_buttons(record)
    content_tag :div, :id => dom_id(record, 'title_and_buttons'), :class => 'title_and_buttons' do
      buttons(record) + title(record)
    end
  end
  
  def buttons(record)
    content_tag :div, :class => 'editbuttons' do
      AdminListButtons.new(record, @controller, ajax_edit?).to_s
    end
  end
  
  def title(record)
    record.title
  end
  
  def ajax_editor_box(record)
    return '' unless ajax_edit?
    content_tag :div, :id => dom_id(record, 'edit_box') do
       ajax_edit_box_closer(record) + content_tag(:div, '', :id => dom_id(record, 'editor'))
    end
  end
  
  def ajax_edit_box_closer(record)
    content_tag :div, :id => dom_id(record, 'edit_box_closer'), :class => 'closer' do
      link_to_function "X", "$('#{dom_id(record, 'editor')}').innerHTML = ''; ['#{dom_id(record, 'edit_box')}', '#{dom_id(record, 'row')}'].each(Element.toggle)"
    end
  end
  
  def ajax_edit?
    @model_klass.respond_to? :ajax_edit or ( model_controller.respond_to? :ajax_edit and model_controller.ajax_edit )
  end
  
  def model_controller
    "Admin/#{@model_klass.to_s.pluralize}Controller".classify.constantize
  end
  
  private
  # This is kind of a hack for testing
  def content_tag_with_block(name, content_or_options_with_block=nil,options={})
    if block_given?
      options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
      content_tag_without_block(name, yield, options)
    else
      content_tag_without_block(name, content_or_options_with_block, options)
    end
  end
  alias_method_chain :content_tag, :block
end