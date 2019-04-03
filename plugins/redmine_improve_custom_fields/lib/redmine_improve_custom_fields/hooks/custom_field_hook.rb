module RedmineImproveCustomFields
  module Hooks
    class CustomFieldHook < Redmine::Hook::ViewListener
      def view_custom_fields_form_upper_box(context = {})
        return content_tag('p', context[:form].check_box(:big_size)) +
                content_tag('p', context[:form].check_box(:hide_label)) +
                content_tag('p', context[:form].check_box(:countable)) +
                content_tag('p', context[:form].select(:mask, Improvecf::MASK.map { |k,v| [k,k] }, include_blank: true)) +
                content_tag('p', context[:form].text_field(:custom_mask))
      end
    end
  end
end
