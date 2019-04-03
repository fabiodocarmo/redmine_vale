class EmailTemplatesController < CrujCrujCrujController
  unloadable

  before_filter :require_admin

    def index_attributes
      [
        :name,
        :subject,
        :template
      ]
    end

end
