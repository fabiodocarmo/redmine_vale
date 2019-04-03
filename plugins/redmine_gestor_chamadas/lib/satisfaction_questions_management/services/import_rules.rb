#encoding: utf-8
module SatisfactionQuestionsManagement
  module Services
    class ImportRules
      require 'roo'

      def self.export_template

        boolean_values = [I18n.t(:general_text_Yes), I18n.t(:general_text_No)]
        package          = Axlsx::Package.new
        workbook         = package.workbook
        satisfaction_questions = SatisfactionQuestion.all
        parameters_sheet_name = 'PARAMETERS'

        workbook.add_worksheet(name: 'TEMPLATE') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_data_validation('E2:E1048576', type: :list, allowBlank: false, formula1: "#{parameters_sheet_name}!$A$2:$A$#{boolean_values.size+1}")

          columns_titles = [:id, :question, :question_en, :question_es, :reopen_enabled]
          sheet.add_row columns_titles, style: title

          satisfaction_questions.find_each do |sq|
            if RUBY_VERSION >= "2.1"
              row = [sq.id, sq.question, sq.question_en, sq.question_es, sq.reopen_enabled ? I18n.t(:general_text_Yes) : I18n.t(:general_text_No)]
            else
              row = [sq.id, sq.question, sq.question_en, sq.question_es, sq.reopen_enabled ? I18n.t(:general_text_Yes) : I18n.t(:general_text_No)]
            end
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        workbook.add_worksheet(name: parameters_sheet_name) do |sheet|
          sheet.add_row [:booleans]
          [boolean_values.size].max.times do |i|
            row = [boolean_values[i]]
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        filename = "tmp/Template_Pesquisa_Satisfacao#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
      end

      def self.import(file)
        spreadsheet = Roo::Spreadsheet.open(file.path, extension: :xlsx)

        errors = []

        invalid_rows = validate_id(spreadsheet)
        errors << I18n.t(:column_invalid_rows, column: :id, rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?

        invalid_rows = validate_reopen_enabled(spreadsheet)
        errors << I18n.t(:column_invalid_rows, column: :reopen_enabled, rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?

        return errors unless errors.blank?

        (2..spreadsheet.last_row).each do |i|
          row = spreadsheet.row(i)

          id = row[0]
          satisfaction_question                  = id ? SatisfactionQuestion.find(id) : SatisfactionQuestion.new
          satisfaction_question.question         = row[1]
          satisfaction_question.question_en      = row[2]
          satisfaction_question.question_es      = row[3]
          satisfaction_question.reopen_enabled   = row[4] == I18n.t(:general_text_Yes) ? true : false


          satisfaction_question.save!
        end

        {}
      end

      protected

      def self.validate_id(spreadsheet)
        validate(0, spreadsheet, SatisfactionQuestion, db_column: :id, nullable: true)
      end

      def self.validate_reopen_enabled(spreadsheet)
        col = 4
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
