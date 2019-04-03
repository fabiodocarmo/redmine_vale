
module XmlValidator

  def self.validate(xml_hash,tracker)

    settings = Setting.send(:plugin_nf_xml_to_form)

    validation_errors = []
    exclusivity_error = false

    return {valid: true, validation_errors: validation_errors, exclusivity_error: exclusivity_error} unless settings[:option]

    settings[:option].each do |k, v|
      if v[:trackers].present?
        if (tracker.in? v[:trackers]) && (xml_hash[settings[k].to_i].blank?)
          validation_errors << CustomField.find(settings[k]).name
        end
      end
      if v[:exclusive_trackers].present?
        if (!tracker.in? v[:exclusive_trackers]) && (xml_hash[settings[k].to_i].present?)
          exclusivity_error = true
        end
      end
    end

    valid = validation_errors.blank? && !exclusivity_error
    {valid: valid, validation_errors: validation_errors, exclusivity_error: exclusivity_error}
  end

end
