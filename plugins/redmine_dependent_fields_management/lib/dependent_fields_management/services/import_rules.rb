#encoding: utf-8
module DependentFieldsManagement
  module Services
    class ImportRules
      require 'roo'

      def self.export_template
        projects = [''] | Project.select(:name).all.map(&:name)
        trackers = [''] | Tracker.select(:name).all.map(&:name)
        dependent_types = DependentField::DEPENDENT_TYPE.keys
        boolean_values = [I18n.t(:general_text_Yes), I18n.t(:general_text_No)]
        custom_fields = CustomField.select(:name).all.map(&:name)

        package          = Axlsx::Package.new
        workbook         = package.workbook
        dependent_fields = DependentField.includes([:project, :tracker, :main_field, :secondary_field])

        parameters_sheet_name = 'PARAMETERS'

        workbook.add_worksheet(name: 'TEMPLATE') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_data_validation('B2:B1048576', type: :list, allowBlank: true, formula1: "#{parameters_sheet_name}!$D$2:$D$#{boolean_values.size+1}")
          sheet.add_data_validation('C2:C1048576', type: :list, allowBlank: true, formula1: "#{parameters_sheet_name}!$C$2:$C$#{dependent_types.size+1}")
          sheet.add_data_validation('D2:D1048576', type: :list, allowBlank: true, formula1: "#{parameters_sheet_name}!$A$2:$A$#{projects.size+1}")
          sheet.add_data_validation('E2:E1048576', type: :list, allowBlank: true, formula1: "#{parameters_sheet_name}!$B$2:$B$#{trackers.size+1}")
          sheet.add_data_validation('F2:F1048576', type: :list, allowBlank: true, formula1: "#{parameters_sheet_name}!$E$2:$E$#{custom_fields.size+1}")
          sheet.add_data_validation('H2:H1048576', type: :list, allowBlank: true, formula1: "#{parameters_sheet_name}!$E$2:$E$#{custom_fields.size+1}")
          sheet.add_data_validation('I2:I1048576', type: :list, allowBlank: true, formula1: "#{parameters_sheet_name}!$D$2:$D$#{boolean_values.size+1}")

          columns_titles = [:id, :avaliable, :dependent_type, :project, :tracker, :main_field, :main_field_value,	:secondary_field,	:not_nullable, 	:secondary_field_value]
          sheet.add_row columns_titles, style: title
          dependent_fields.find_each do |df|
            if RUBY_VERSION >= "2.1"
              row = [df.id, df.avaliable ? I18n.t(:general_text_Yes) : I18n.t(:general_text_No), df.dependent_type, df.project.try(:name), df.tracker.try(:name), df.main_field.try(:name), df.main_field_value, df.secondary_field.try(:name), df.not_nullable ? I18n.t(:general_text_Yes) : I18n.t(:general_text_No), df.secondary_field_value]
            else
              row = [df.id, df.avaliable ? I18n.t(:general_text_Yes) : I18n.t(:general_text_No), df.dependent_type, df.project.try(:name), df.tracker.try(:name), df.main_field.try(:name), df.main_field_value, df.secondary_field.blank? ? df.secondary_field : nil, df.not_nullable ? I18n.t(:general_text_Yes) : I18n.t(:general_text_No), df.secondary_field_value]
            end
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        workbook.add_worksheet(name: parameters_sheet_name) do |sheet|
          sheet.add_row [:project, :tracker, :dependent_type, :booleans, :custom_field]
          [projects.size, trackers.size, dependent_types.size, boolean_values.size, custom_fields.size].max.times do |i|
            row = [projects[i], trackers[i], dependent_types[i], boolean_values[i], custom_fields[i]]
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        filename = "tmp/template_dependent_field#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
      end

      def self.import(file)
        spreadsheet = Roo::Spreadsheet.open(file.path, extension: :xlsx)

        errors = []

        invalid_rows = validate_id(spreadsheet)
        errors << I18n.t(:column_invalid_rows, column: :id, rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?

        invalid_rows = validate_avaliable(spreadsheet)
        errors << I18n.t(:column_invalid_rows, column: :avaliable, rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?

        invalid_rows = validate_dependent_type(spreadsheet)
        errors << I18n.t(:column_invalid_rows, column: :dependent_type, rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?

        invalid_rows = validate_project(spreadsheet)
        errors << I18n.t(:column_invalid_rows, column: :project, rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?

        invalid_rows = validate_tracker(spreadsheet)
        errors << I18n.t(:column_invalid_rows, column: :tracker, rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?

        invalid_rows = validate_main_field(spreadsheet)
        errors << I18n.t(:column_invalid_rows, column: :main_field, rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?

        invalid_rows = validate_secondary_field(spreadsheet)
        errors << I18n.t(:column_invalid_rows, column: :secondary_field, rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?

        invalid_rows = validate_not_nullable(spreadsheet)
        errors << I18n.t(:column_invalid_rows, column: :not_nullable, rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?

        return errors unless errors.blank?

        (2..spreadsheet.last_row).each do |i|
          row = spreadsheet.row(i)

          id = row[0]
          dependent_field                       = id ? DependentField.find(id) : DependentField.new
          dependent_field.avaliable             = row[1] == I18n.t(:general_text_Yes) ? true : false
          dependent_field.dependent_type        = row[2]
          dependent_field.project               = Project.where(name: row[3]).first
          dependent_field.tracker               = Tracker.where(name: row[4]).first
          dependent_field.main_field            = CustomField.where(name: row[5]).first
          dependent_field.main_field_value      = row[6]
          dependent_field.main_field_value      = spreadsheet.celltype(i, 7) == :float ? spreadsheet.send(:cell_to_csv, i, 7, spreadsheet.default_sheet) : row[6]
          dependent_field.secondary_field       = CustomField.where(name: row[7]).first
          dependent_field.not_nullable          = row[8] == I18n.t(:general_text_Yes) ? true : false
          dependent_field.secondary_field_value = spreadsheet.celltype(i, 10) == :float ? spreadsheet.send(:cell_to_csv, i, 10, spreadsheet.default_sheet) : row[9]

          dependent_field.save!
        end

        {}
      end

      protected

      def self.validate_id(spreadsheet)
        validate(0, spreadsheet, DependentField, db_column: :id, nullable: true)
      end

      def self.validate_avaliable(spreadsheet)
        col = 1
        (2..spreadsheet.last_row)
          .map { |i| {i => [I18n.t(:general_text_No), I18n.t(:general_text_Yes)].include?(spreadsheet.row(i)[col]) } }
          .select { |e| !e.values.first }
          .map { |e| e.keys.first }
      end

      def self.validate_dependent_type(spreadsheet)
        col = 2
        (2..spreadsheet.last_row).reject { |i| DependentField::DEPENDENT_TYPE.keys.map(&:to_s).include?(spreadsheet.row(i)[col]) }
      end

      def self.validate_project(spreadsheet)
        validate(3, spreadsheet, Project, nullable: true)
      end

      def self.validate_tracker(spreadsheet)
        validate(4, spreadsheet, Tracker, nullable: true)
      end

      def self.validate_main_field(spreadsheet)
        validate(5, spreadsheet, CustomField)
      end

      def self.validate_secondary_field(spreadsheet)
        validate(7, spreadsheet, CustomField)
      end

      def self.validate_not_nullable(spreadsheet)
        col = 8
        (2..spreadsheet.last_row)
          .map { |i| {i => [I18n.t(:general_text_No), I18n.t(:general_text_Yes)].include?(spreadsheet.row(i)[col]) } }
          .select { |e| !e.values.first }
          .map { |e| e.keys.first }
      end


      def self.validate(col, spreadsheet, clazz, options = {})
        db_column = options[:db_column] || :name
        nullable = options[:nullable] || false
        (2..spreadsheet.last_row).map do |i|
          value = spreadsheet.row(i)[col]
          { i => (nullable && !value) || clazz.where(db_column => value).first }
        end
        .select { |e| !e.values.first }
        .map { |e| e.keys.first }
      end
    end
  end
end
