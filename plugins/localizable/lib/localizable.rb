# encoding: UTF-8

# Copyright © Emilio González Montaña
# Licence: Attribution & no derivates
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/localizable
#   * No derivates of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

module Localizable

  def self.included(base)
    base.extend(ClassMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in developmen

      include Redmine::I18n

      def name(original = false)
        return(original ? super() : self.class.localize(id, super()))
      end
    end
  end

  module ClassMethods
    def localize(id, name)
      value = name

      if Setting["plugin_localizable"]
        if Setting["plugin_localizable"]["locales"]
          if Setting["plugin_localizable"]["locales"][localize_type]
            if Setting["plugin_localizable"]["locales"][localize_type][id.to_s]
              unless Setting["plugin_localizable"]["locales"][localize_type][id.to_s][current_language.to_s].blank?
                value = Setting["plugin_localizable"]["locales"][localize_type][id.to_s][current_language.to_s]
              end
            end
          end
        end
      end

      return(value)
    end

    def localize_type
      @localize_type ||= (self.superclass.to_s == "ActiveRecord::Base" ? self : self.superclass).name.underscore
    end
  end

end
