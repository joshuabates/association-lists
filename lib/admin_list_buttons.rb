class AdminListButtons
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  
  # It would be nice to get the verb and URL info via introspection, but I think that may be a bit of a pain
  ACTIONS = {
    :destroy    => [:delete],
    :edit       => [:get, 'edit'],
    :published  => [:put, 'toggle_published'],
    :featured   => [:put, 'toggle_featured'],
    :translate  => [:get, 'translate']
  }
  
  attr_reader :controller
  delegate :link_to, :to => :controller
  delegate :link_to_remote, :to => :controller
  
  def initialize(record, controller, ajax_edit=true)
    @record, @controller, @ajax_edit = record, controller, ajax_edit
  end
  
  # Create all the action methods
  ACTIONS.each do |action, options|
    class_eval <<-EOE
      def #{action}
        #{"return unless @record.respond_to? :#{action}" unless action == :edit}
        button(:#{action})
      end
    EOE
  end
  
  # Return a string with all the valid buttons
  def to_s
    ACTIONS.keys.map do |action|
      send(action.to_sym)
    end.join('')
  end
  
  def button(action)
    # TODO: Should there just be a greyed out button if the user doesn't have permission?
    return unless permitted?(action)
    
    # TODO: Return a lock icon for delete if the record is locked
    return locked_button if locked?(action)
    url = action_url(action)
    unless action == :edit and !@ajax_edit
      link_to_remote( icon(action), :url => url, :method => action_method(action), :confirm => popup_confirmation(action) )
    else
      link_to(icon(action), url)
    end
  end
  
  def locked_button
    image_tag("/images/icons/locked.gif")
  end
  
  def popup_confirmation(action)
    if action_method(action) == :delete
      "Are you sure you want to #{action.to_s.humanize.downcase} this #{@record.class.to_s.humanize.downcase}?"
    else
      nil
    end
  end
  
  def action_method(action)
    ACTIONS[action].first
  end
  
  def action_url(action)
    url = ['admin', ACTIONS[action][1], @record.class.base_class.to_s.underscore, 'url'].compact.join('_')
    @controller.send(url, @record)
  end
  
  def icon(action)
    image_tag("/images/icons/#{image_name(action)}.gif")
  end
  
  def image_name(action)
    return action unless boolean? action
    on_or_off = @record.send("#{action}?".to_sym) ? 'off' : 'on'
    "#{action}_#{on_or_off}"
  end
  
  # This is not foolproof, perhaps I should also be checking for a tinyint column type (not db agnostic?)
  def boolean?(action)
    @record.respond_to? "#{action}?".to_sym
  end
  
  # Checks if the action is permitted. I should probably be checking based on url, or atleest get the controller
  # to check via routing introspection
  def permitted?(action)
    return true unless @controller.respond_to? :has_permission_for?
    @controller.has_permission_for?(action)
  end
  
  def locked?(action)
    # TODO: Should actions other than destroy be lockable?
    action == :destroy and @record.respond_to? :locked and @record.locked?
  end
end