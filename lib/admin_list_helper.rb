module AdminListHelper
  def admin_list(model_name, options={})
    AdminList.new(model_name, self, options).to_list
  end
end