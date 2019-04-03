module Cepom
  class CepomRjJob < ExecJob
    URL = 'https://dief.rio.rj.gov.br/dief/asp/cepom/consulta_situacao_empresas_prestadoras.asp'.freeze

    NOT_IN_CEPOM = 'Pessoa jurdica no cadastrada como prestador de servios'.freeze

    def perform(issue)
      issue = issue.is_a?(Issue) ? issue : Issue.find(issue)

      lc   = fix_cepom_lc_error(issue.custom_field_value(config[:lc_field]))

      city = issue.custom_field_value(config[:city_field])

      return unless lc.first.present? && should_exec_cepom(issue, lc, city)

      cnpj = issue.custom_field_value(config[:cnpj_field])

      return unless cnpj && lc

      cepom_result = consulta_cnpj(cnpj, lc)

      issue.custom_field_values = {
        config[:cepom_field] => cepom_result[0],
        config[:notification_field] => cepom_result[1]
      }
    end

    private

    def fix_cepom_lc_error(lc)
      lc_array = []

      lc_array << lc
      if lc == '13.05'
        lc_array << '13.04'
      elsif lc == '17.14'
        lc_array << '17.13'
      end
      lc_array
    end

    def should_exec_cepom(issue, lc, city)
      excludes_lcs    = config[:exclude_lc_codes]
      excludes_cities = config[:exclude_city_codes]

      excludes_lcs.blank? || !excludes_lcs.gsub("\r","").split("\n").include?(lc.first) ||
        excludes_cities.blank? || !excludes_cities.gsub("\r","").split("\n").include?(city)
    end

    def consulta_cnpj(cnpj, lc)
      situation = []

      browser = Mechanize.new

      browser.get(URL) do |page|
        situation = fetch_situation(page, cnpj, lc)
      end

      situation
    end

    def fetch_situation(page, cnpj, lc)
      new_page = submit_form(page, cnpj)

      page_translated = new_page.body.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      page_translated = Nokogiri::HTML::Document.parse(page_translated, nil, 'UTF-8')

      page_translated_text = page_translated.text

      if page_translated_text.include?(NOT_IN_CEPOM)
        [config[:cepom_not_found_value], config[:not_on_cepom_message]]
      elsif !lc.map { |lc| page_translated_text.include?(lc) }.reduce(&:|)
        [config[:cepom_not_found_value], config[:not_found_lc_message]]
      else
        [config[:cepom_found_value], config[:on_cepom_message]]
      end
    end

    def submit_form(page, cnpj)
      page.form_with(name: 'formsituacao') do |form|
        input_cnpj = form.field_with(type: 'text')
        input_cnpj.value = cnpj
      end.submit
    end

    def self.schema
      {
        cnpj_field: issue_custom_field_schema,
        cepom_field: issue_custom_field_schema,
        lc_field: issue_custom_field_schema,
        city_field: issue_custom_field_schema,
        notification_field: issue_custom_field_schema,
        cepom_found_value: string_field_schema,
        cepom_not_found_value: string_field_schema,
        exclude_city_codes: text_field_schema,
        exclude_lc_codes: text_field_schema,
        not_on_cepom_message: text_field_schema,
        not_found_lc_message: text_field_schema,
        on_cepom_message: text_field_schema,
      }
    end
  end
end
