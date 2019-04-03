module TranslateHelper
  def translate(value, type)
    if Setting["plugin_localizable"]
      if Setting["plugin_localizable"]["locales"]
        if Setting["plugin_localizable"]["locales"][type]
          if Setting["plugin_localizable"]["locales"][type][value]
            unless Setting["plugin_localizable"]["locales"][type][value][User.current.language.to_s].blank?
              value = Setting["plugin_localizable"]["locales"][type][value][User.current.language.to_s]
            end
          end
        end
      end
    end
    return(value)
  end

  def translate_value(value, type)
    if !translate(value, type).nil?
      value = translate(value, type)
    else
      value
    end
  end
end
