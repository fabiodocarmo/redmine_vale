module Patches
  module FieldFormatPatch

    class GridFormat < Redmine::FieldFormat::Unbounded
      add 'grid'
      self.form_partial = 'custom_fields/formats/grid'

      def self.name_id
        'grid'
      end

      def validate_custom_value(custom_value)
        if custom_value.required? && value_blank?(custom_value.value)
          [::I18n.t('activerecord.errors.messages.blank')]
        else
          return []
        end
      end

      def value_blank?(value)
        return true if value.blank?
        JSON.parse(value.gsub('=>', ':')).values.map(&:values).flatten.inject(:+).blank?
      end

      def formatted_value(view, custom_field, value, customized=nil, html=false)
        if view.action_name == "index" #Exportação TODO; Fazer isso de um jeito mais bonito
          super(view, custom_field, value, customized, html)
        elsif value.blank?
          value
        else
          generate_table_view(view,custom_field, value)
        end
      end

      def generate_table_view(view, custom_field, hash_as_string)
        columns = custom_field.sorted_grid_columns
        values = JSON.parse hash_as_string.gsub('=>',':')
        timestamp = DateTime.now.strftime('%Q')

        t_head = view.content_tag(:thead) do
          view.content_tag(:tr) do
            columns.collect { |column| view.concat view.content_tag(:th, column.name) }.join().html_safe
          end
        end

        t_body = view.content_tag(:tbody) do
          values.collect { |row_index,row|
            view.content_tag :tr do
              columns.collect{ |column|
                view.concat view.content_tag(:td, row[column.id.to_s], style: 'background-color: white; color: black;')
              }.to_s.html_safe
            end
          }.join().html_safe
        end
        table = view.content_tag(:table, t_head.concat(t_body), id: 'grid_custom_field_table_'+custom_field.id.to_s+'-'+timestamp, class: 'list')
        view.content_tag(:div, table, id: 'grid_pop_up_'+custom_field.id.to_s+'-'+timestamp, style: 'display: none') +
        view.button_tag(type: 'button', id: 'grid_custom_field_show_'+custom_field.id.to_s+'-'+timestamp) do
           view.concat view.image_tag("/images/magnifier.png")
        end
      end

      def edit_tag(view, tag_id, tag_name, custom_value, options={})
        columns = custom_value.custom_field.sorted_grid_columns
        values = custom_value.value

        rows = {}
        cells = {}

        if values.blank?
          rows["0"] = {}
          columns.each do |c|
            rows["0"][c.id.to_s] = CustomFieldValue.new(customized:custom_value.customized, custom_field: c, value:c.default_value)
          end
        else
          values = JSON.parse values.gsub('=>',':')
          values.each do |k, value|
            columns.each do |col|
              val = value[col.id.to_s]
              rows[k] ||= {}
              rows[k][col.id.to_s] = CustomFieldValue.new(customized:custom_value.customized, custom_field: col, value:val)
            end
            #row_index = value.row.to_s
            #rows[row_index] ||= {}
            #rows[row_index][value.column_custom_field.id.to_s] = CustomFieldValue.new(customized:custom_value.customized, custom_field: value.column_custom_field, value:value.value)
          end
        end
        prefix = custom_value.custom_field.id.to_s + '_'

        head_delete = view.content_tag(:th, ' ')

        body_delete = view.content_tag(:td, style: 'background-color: white;
  color: black;') do
          view.button_tag(type: 'button', id: 'grid_custom_field_delete_row_'+custom_value.custom_field_id.to_s) do
            view.concat view.content_tag(:strong, l(:grid_custom_field_delete_row))
          end
        end

        t_head = view.content_tag(:thead) do
          view.content_tag(:tr) do
            #TODO encontrar uma maneira melhor de passar o valor default do que usar a class aqui
            columns.collect { |column| view.concat view.content_tag(:th, column.name + (column.is_required? ? "*".html_safe : ""), title: column.description.presence, class: column.default_value) }.join().html_safe
            view.concat head_delete
          end
        end

        t_body = view.content_tag(:tbody) do
          rows.collect { |row_index,row|
            view.content_tag :tr do
              columns.collect{ |column|
                view.concat view.content_tag(:td, view.grid_field_tag((prefix + row_index).to_sym, row[column.id.to_s]), style: 'background-color: white;
  color: black;')
              }.to_s.html_safe
            view.concat body_delete
            end
          }.join().html_safe
        end
        table = view.content_tag(:table, t_head.concat(t_body), id: 'grid_custom_field_table_'+custom_value.custom_field_id.to_s, class: 'list') +
        view.button_tag(type: 'button', id: 'grid_custom_field_add_row_'+custom_value.custom_field_id.to_s) do
           view.concat view.content_tag(:strong, l(:grid_custom_field_add_row))
        end

        view.content_tag(:div, table, id: 'grid_pop_up_'+custom_value.custom_field_id.to_s) +
        view.button_tag(type: 'button', id: 'grid_custom_field_show_'+custom_value.custom_field_id.to_s) do
           view.concat view.image_tag("/images/edit.png?1431620602")
        end
      end
    end
  end
end
