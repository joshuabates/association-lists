class AdminListsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory File.join('public/stylesheets')
      m.directory File.join('public/images/icons')
      
      m.template 'admin_lists.css',   File.join('public/stylesheets', "admin_lists.css")
      m.template 'destroy.gif',       File.join('public/images/icons', "destroy.gif")
      m.template 'edit.gif',          File.join('public/images/icons', "edit.gif")
      m.template 'featured_off.gif',  File.join('public/images/icons', "featured_off.gif")
      m.template 'featured_on.gif',   File.join('public/images/icons', "featured_on.gif")
      m.template 'locked.gif',        File.join('public/images/icons', "locked.gif")
      m.template 'published_off.gif', File.join('public/images/icons', "published_off.gif")
      m.template 'published_on.gif',  File.join('public/images/icons', "published_on.gif")
      m.template 'translate.gif',     File.join('public/images/icons', "translate.gif")
    end
  end
end