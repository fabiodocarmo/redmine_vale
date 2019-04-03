class SqlReport < ActiveRecord::Base
  unloadable
  serialize :filters, HashWithIndifferentAccess

  attr_protected :name, :sql, :filters, :sql_template_attributes, as: :admin

  has_one :sql_template, dependent: :destroy
  accepts_nested_attributes_for :sql_template

  def snake_case_name
    I18n.transliterate(self.name).titleize.split.join.underscore.to_sym
  end

  def self.build_xlsx(sql_report_id, filters)
    sql_report = SqlReport.find(sql_report_id)

    if sql_report.sql_template
      workbook = build_with_template(sql_report.sql_template, filters)
    else
      workbook = Fastxl.create
      workbook = build_with_sql(workbook, 1, sql_report.sql, filters)
    end

    workbook
  end

  def self.build_with_template(sql_template, filters)
    workbook = build_workbook(sql_template)

    sql_template.sql_template_worksheets.each do |sql_worksheet|
      if sql_worksheet.sql.present?
        workbook = build_with_sql(workbook, sql_worksheet.sheet_index, sql_worksheet.sql, filters)
      end
    end

    workbook
  end

  def self.build_workbook(sql_template)
    Fastxl.open(sql_template.attachment.diskfile)
  end

  def self.build_with_sql(workbook, sheet_index, sql, filters)
    result    = query_result(sql, filters)

    sheet_content = []

    add_column(sheet_content, result)
    add_rows(sheet_content, result)

    workbook.write(sheet_index, sheet_content)

    workbook
  end

  def self.query_result(sql, filters)
    ReportsReplicaDb.run_query(sql, filters)
  end

  def self.add_column(sheet_content, result)
    sheet_content << result.columns
    sheet_content
  end

  def self.add_rows(sheet_content, result)
    result.each_with_index do |row, i|
      sheet_content << row.values
    end

    sheet_content
  end
end
