module GestorChamadas
  # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
  module ApplicationControllerPatch
    def self.included(base) # :nodoc
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in developmen
        alias_method_chain :require_login, :to_gestor
      end
    end

    module ClassMethods

    end

    module InstanceMethods
      def require_login_with_to_gestor
        if !User.current.logged?
          respond_to do |format|
            format.html {
              if request.xhr?
                head :unauthorized
              else
                redirect_to gestor_chamados_projects_path
              end
            }
            format.atom { redirect_to :controller => "account", :action => "login", :back_url => url }
            format.xml  { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
            format.js   { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
            format.json { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
          end

          return false
        end
        true
      end
    end
  end
end
