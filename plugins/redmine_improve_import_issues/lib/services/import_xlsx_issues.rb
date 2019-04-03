#encoding: utf-8
module Services
  class ImportXlsxIssues
    require 'roo'

    def self.import_xlsx_issues(import)
      spreadsheet = Roo::Spreadsheet.open(import.settings["diskfile"], extension: :xlsx)

      # errors = []
      #
      # invalid_rows = validate_project(spreadsheet)
      # errors << I18n.t(:column_invalid_rows, column: 'Projeto', rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?
      #
      # invalid_rows = validate_tracker(spreadsheet)
      # errors << I18n.t(:column_invalid_rows, column: 'Tipo de Problema', rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?
      #
      # invalid_rows = validate_group(spreadsheet)
      # errors << I18n.t(:column_invalid_rows, column: 'Grupo de Atendentes', rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?
      #
      # invalid_rows = validate_second_group(spreadsheet)
      # errors << I18n.t(:column_invalid_rows, column: 'Grupo de Atendentes (Fim de Semana)', rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?
      #
      # invalid_rows = validate_status_from(spreadsheet)
      # errors << I18n.t(:column_invalid_rows, column: 'Status de', rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?
      #
      # invalid_rows = validate_status_to(spreadsheet)
      # errors << I18n.t(:column_invalid_rows, column: 'Status para', rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?
      #
      # invalid_rows = validate_redistribute(spreadsheet)
      # errors << I18n.t(:column_invalid_rows, column: 'Redistribuir por Carga de Trabalho', rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?
      #
      # invalid_rows = validate_use_custom_field(spreadsheet)
      # errors << I18n.t(:column_invalid_rows, column: 'Usar Campo Personalizado', rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?
      #
      # invalid_rows = validate_custom_field(spreadsheet)
      # errors << I18n.t(:column_invalid_rows, column: 'Campo Personalizado', rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?
      #
      # invalid_rows = validate_second_custom_field(spreadsheet)
      # errors << I18n.t(:column_invalid_rows, column: 'Segundo Campo Personalizado', rows: invalid_rows.first(25).join(', ')) unless invalid_rows.blank?
      #
      # return errors unless errors.blank?
      saved_issues = {
        success: [],
        unsuccess: []

      }
      (2..spreadsheet.last_row).each do |i|
        row = spreadsheet.row(i)

        issue = Issue.new
        issue.project = Project.where(id: import.settings["project_id"]).first
        issue.tracker = Tracker.where(id: import.settings["tracker_id"]).first
        issue.status = issue.tracker.default_status
        issue.author = import.settings["current_user"]
        issue.subject = Tracker.where(id: import.settings["tracker_id"]).first.name

        issue.custom_field_values = import.settings["custom_fields"]
                                          .each_with_index
                                          .map { |cv, idx| [cv, row[idx]] }
                                          .to_h

        errors = {}

        if issue.save
          saved_issues[:success] << {"row": i, "issue": issue}
        else
          saved_issues[:unsuccess] << { "row": i, "issue": issue}
        end

        saved_issues[:unsuccess].each do |issue_hash|
        	issue_hash[:issue].errors.full_messages.each do |e|
        		errors[e] ||= []
        		errors[e] << issue_hash[:row]
        	end
        end

        saved_issues[:errors] = errors

        # atribuicao_automatica.group        = Group.where(lastname:     row[3]).first
        # atribuicao_automatica.weekend_group = Group.where(lastname:     row[4]).first
        #
        # status_from = row[5]
        # atribuicao_automatica.status_from  = status_from && IssueStatus.where(name: status_from).first
        # atribuicao_automatica.status_to    =                IssueStatus.where(name:      row[6]).first
        #
        # atribuicao_automatica.redistribute = row[7].blank? ?
        #                       '' : (AtribuicaoAutomatica::REDISTRIBUTE_TYPE).select {|k, v| v == row[7]}.first.first
        #
        # atribuicao_automatica.use_custom_field = row[8] == I18n.t(:general_text_Yes) ? true : false
        #
        # atribuicao_automatica.custom_field = CustomField.where(name: row[9]).first
        # atribuicao_automatica.custom_field_value = spreadsheet.celltype(i, 10) == :float ?
        #                                     spreadsheet.send(:cell_to_csv, i, 11, spreadsheet.default_sheet) : row[10]
        #
        # atribuicao_automatica.second_custom_field = CustomField.where(name: row[11]).first
        # atribuicao_automatica.second_custom_field_value = spreadsheet.celltype(i, 12) == :float ?
        #                                     spreadsheet.send(:cell_to_csv, i, 13, spreadsheet.default_sheet) : row[12]
        #
        #
        # atribuicao_automatica.save!
      end

      saved_issues
    end

    protected

    def self.validate_project(spreadsheet)
      validate(1, spreadsheet, Project, db_column: :identifier)
    end

    def self.validate_tracker(spreadsheet)
      validate(2, spreadsheet, Tracker)
    end

    def self.validate_group(spreadsheet)
      validate(3, spreadsheet, Group, db_column: :lastname)
    end

    def self.validate_second_group(spreadsheet)
      validate(4, spreadsheet, Group, db_column: :lastname, nullable: true)
    end

    def self.validate_status_from(spreadsheet)
      validate(5, spreadsheet, IssueStatus, nullable: true)
    end

    def self.validate_status_to(spreadsheet)
      validate(6, spreadsheet, IssueStatus)
    end

    def self.validate_redistribute(spreadsheet)
      col = 7
      (2..spreadsheet.last_row)
        .map { |i| {i => (['', nil] | AtribuicaoAutomatica::REDISTRIBUTE_TYPE.values).include?(spreadsheet.row(i)[col]) } }
        .select { |e| !e.values.first }
        .map { |e| e.keys.first }
    end

    def self.validate_use_custom_field(spreadsheet)
      col = 8
      (2..spreadsheet.last_row)
        .map { |i| {i => [I18n.t(:general_text_No), I18n.t(:general_text_Yes)].include?(spreadsheet.row(i)[col]) } }
        .select { |e| !e.values.first }
        .map { |e| e.keys.first }
    end

    def self.validate_custom_field(spreadsheet)
      validate(9, spreadsheet, CustomField, nullable: true)
    end

    def self.validate_second_custom_field(spreadsheet)
      validate(11, spreadsheet, CustomField, nullable: true)
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
