# This file is a part of Redmine CRM (redmine_contacts) plugin,
# customer relationship management plugin for Redmine
#
# Copyright (C) 2011-2014 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_contacts is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_contacts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_contacts.  If not, see <http://www.gnu.org/licenses/>.

module GestorChamadas
  module IssuePatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
#        has_and_belongs_to_many :contacts, uniq: true, autosave: true

        validate :check_copy_to_same_project, if: 'Setting.plugin_redmine_gestor_chamadas[:forward_same_project] == "true" && @copied_from'
        validate :check_parent_is_closed, if: 'self.tracker_id.to_s.in? Setting.plugin_redmine_gestor_chamadas[:closing_child_issues_enabled]'
#       before_validation :clean_value_field
        before_validation :rollback_forwarding          , if: '!Setting.plugin_redmine_gestor_chamadas[:mistaken_status].blank? && !Setting.plugin_redmine_gestor_chamadas[:high_priority].blank?     && status.id == Setting.plugin_redmine_gestor_chamadas[:mistaken_status].to_i'

        before_save :check_reopened_issue

#        after_create :set_supplier
        after_update :mark_as_answered_priority, unless: 'Setting.plugin_redmine_gestor_chamadas[:answered_priority].blank?'
        after_update :cascade_priority, if: 'Setting.plugin_redmine_gestor_chamadas[:cascade_priority] == "true"' && :priority_id_changed?
        after_update :change_parent_status_if_children_answered, if: 'Setting.plugin_redmine_gestor_chamadas[:enable_change_status_in_copy] == "true"'  && :status_id_changed?
        after_create :change_parent_status_if_copied, if: 'Setting.plugin_redmine_gestor_chamadas[:enable_change_status_in_copy] == "true"'
        after_save :increase_priority          , if: '!Setting.plugin_redmine_gestor_chamadas[:mistaken_status].blank? && !Setting.plugin_redmine_gestor_chamadas[:high_priority].blank?  && status.id == Setting.plugin_redmine_gestor_chamadas[:mistaken_status].to_i && Setting.plugin_redmine_gestor_chamadas[:enable_change_status_in_copy] != "true"'
        before_save :add_satisfaction_survey_journal, if: 'Setting.plugin_redmine_gestor_chamadas[:enable_satisfaction_survey] == "true"'
        after_save :close_child_issues
        alias_method_chain :copy_from, :sla
        alias_method_chain :assignable_users, :only_project_assignable
        # alias_method_chain :new_statuses_allowed_to, :transition_workflow_from_same_status
        alias_method_chain :editable?, :disabled_archived_edit
        alias_method_chain :attributes_editable?, :disabled_archived_edit
      end
    end

    module InstanceMethods

      def close_child_issues
        return false if Setting.plugin_redmine_gestor_chamadas[:closing_child_issues_enabled].blank?
        if ((self.status.is_closed?) && (self.tracker_id.to_s.in?Setting.plugin_redmine_gestor_chamadas[:closing_child_issues_enabled]))
          #Fecha os chamados filhos
          filhos = Array.new
          filhos = Issue.where(:parent_id => self.id)
          for filho in filhos do
            if !filho.status.is_closed?
              systemuser = User.find(12379)
              encaminhado.init_journal(systemuser)
              if IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:canceled_status]).blank?
                  filho.status_id = self.status_id
              else
                filho.status = IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:canceled_status])
              end
              filho.save(validate: false)
            end
          end

          #Fecha os chamados encaminhados
          relacao_encaminhado = Array.new
          relacao_encaminhado = IssueRelation.where(:issue_from_id => self.id, :relation_type => "copied_to")
          encaminhados = Array.new
          for r in relacao_encaminhado do
            encaminhados += Issue.where(:id => r.issue_to_id)
          end
          for encaminhado in encaminhados do
            if !encaminhado.status.is_closed?
              systemuser = User.find(12379)
              encaminhado.init_journal(systemuser)
              if IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:canceled_status]).blank?
                encaminhado.status_id = self.status_id
              else
                encaminhado.status = IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:canceled_status])
              end
              encaminhado.save(validate: false)
            end
          end
        end
      end

      def check_reopened_issue
        return unless self.was_closed? && !self.status.is_closed?
        parent_relation = IssueRelation.where(:issue_to_id => self.id, :relation_type => "copied_to")
        return unless !parent_relation.blank?
        parent_issue = Issue.find(parent_relation.first.issue_from_id)
        return unless parent_issue.tracker_id.to_s.in? Setting.plugin_redmine_gestor_chamadas[:enable_only_one_child]

        if parent_issue.only_one_child_issue? == false
          errors.add :base, I18n.t('activerecord.errors.messages.reopen_not_allowed', issue: parent_issue.id)
          return false
        end

        return unless parent_issue.tracker_id.to_s.in? Setting.plugin_redmine_gestor_chamadas[:change_status_copy_trackers]

        if parent_issue.status_id.to_s == Setting.plugin_redmine_gestor_chamadas[:answered_status_to]
          systemuser = User.find(12379)
          parent_issue.init_journal(systemuser)
          parent_issue.status_id = Setting.plugin_redmine_gestor_chamadas[:copied_status_to]
          parent_issue.save
        elsif
          errors.add :base, I18n.t('activerecord.errors.messages.reopen_not_allowed_father_not_answered', issue: parent_issue.id, status: Setting.plugin_redmine_gestor_chamadas[:answered_status_to])
          return false
        end

      end

      def only_one_child_issue?
        return true if self.status.is_closed?
        if self.tracker_id.to_s.in?Setting.plugin_redmine_gestor_chamadas[:enable_only_one_child]
          filhos_temp = Array.new
          filhos_temp = Issue.where(:parent_id => self.id)
          filhos = Array.new
          for f in filhos_temp do
            if f.status.is_closed? == false
              filhos += Issue.where(:id => f.id)
            end
          end
          relacao_encaminhado = Array.new
          relacao_encaminhado = IssueRelation.where(:issue_from_id => self.id, :relation_type => "copied_to")
          encaminhados_temp = Array.new
          for r in relacao_encaminhado do
            encaminhados_temp += Issue.where(:id => r.issue_to_id)
          end
          encaminhados = Array.new
          for e in encaminhados_temp do
            if e.status.is_closed? == false
              encaminhados += Issue.where(:id => e.id)
            end
          end

          if ((filhos.length >= 1) || (encaminhados.length >= 1))
            return false
          end
          return true
        end
        return true
      end


      def new_statuses_allowed_to_with_transition_workflow_from_same_status(user=User.current, include_default=false)
        if new_record? && @copied_from
          [default_status, @copied_from.status].compact.uniq.sort
        else
          initial_status = nil
          if new_record?
            initial_status = default_status
          elsif tracker_id_changed?
            if Tracker.where(:id => tracker_id_was, :default_status_id => status_id_was).any?
              initial_status = default_status
            elsif tracker.issue_status_ids.include?(status_id_was)
              initial_status = IssueStatus.find_by_id(status_id_was)
            else
              initial_status = default_status
            end
          else
            initial_status = status_was
          end

          initial_assigned_to_id = assigned_to_id_changed? ? assigned_to_id_was : assigned_to_id
          assignee_transitions_allowed = initial_assigned_to_id.present? &&
            (user.id == initial_assigned_to_id || user.group_ids.include?(initial_assigned_to_id))

          statuses = []
          if initial_status
            statuses += initial_status.find_new_statuses_allowed_to(
              user.admin ? Role.all.to_a : user.roles_for_project(project),
              tracker,
              author == user,
              assignee_transitions_allowed
              )
          end
          # statuses << initial_status unless statuses.empty?
          statuses << default_status if include_default
          statuses = statuses.compact.uniq.sort
          if blocked?
            statuses.reject!(&:is_closed?)
          end
          statuses
        end
      end

      def assignable_users_with_only_project_assignable
        project.assignable_users
      end

      def set_supplier
        return unless cpf_cnpj_field_id = Setting.plugin_redmine_gestor_chamadas[:customer_field]
        cpf_cnpj_value = custom_field_value(cpf_cnpj_field_id)

        return unless cpf_cnpj_value

        cpf_cnpj_value.gsub!(/[^0-9]+/, '')

        if cpf_cnpj_value.length == 14
          cpf_cnpj_value = cpf_cnpj_value[0..7]
        end

        if cpf_cnpj = CpfCnpj.where(value: cpf_cnpj_value).first
          company = cpf_cnpj.contact
        else
          social_name = custom_field_value(Setting.plugin_redmine_gestor_chamadas[:social_name])
          return unless social_name

          company  = Contact.new(first_name: social_name, is_company: true, email: contacts.first.email)
          company.project = project
          company.save!

          cpf_cnpj = CpfCnpj.new(value: cpf_cnpj_value)
          cpf_cnpj.contact = company
          cpf_cnpj.save!
        end

        contacts.update_all(company: company.first_name)
      end

      def clean_value_field
        available_custom_fields.each do |custom_field|
          next if custom_field.field_format != "float"

          value = custom_field_value(custom_field)
          return true if value.blank?

          self.custom_field_values = { custom_field.id => value.gsub(',', '.') }
        end
      end

      def copy_from_with_sla(arg, options={})
        issue = arg.is_a?(Issue) ? arg : Issue.visible.find(arg)
        self.attributes = issue.attributes.dup.except("id", "root_id", "parent_id", "lft", "rgt", "created_on", "updated_on", "start_on", "data_atualizada", "due_date", "start_date", "sla_id", "assigned_to_id", "status_id")

        self.custom_field_values = issue.custom_field_values.inject({}) {|h,v| h[v.custom_field_id] = v.value; h}

        self.author = User.current
        unless options[:attachments] == false
          self.attachments = issue.attachments.map do |attachement|
            attachement.copy(:container => self)
          end
        end
        @copied_from = issue
        @copy_options = options
        self
      end

      def change_to_last_assigned
        return if Setting.plugin_redmine_gestor_chamadas[:mistaken_change_assigned] != "true"
        p 'change_to_last_assigned'

        last_assigned_id = self.journals.joins(:details).where(journal_details:{prop_key:'assigned_to_id'}).order('journal_details.id DESC').select("journal_details.old_value").first.old_value

        self.assigned_to = User.find(last_assigned_id)

      end

      def rollback_forwarding
        return if Setting.plugin_redmine_gestor_chamadas[:mistaken_change_assigned] != "true"
        #Contorna o save do sla que faz entrar aqui de novo. Remover após consertar sla
        current_journal.details.each do |detail|
          return if detail.prop_key == 'project_id'
        end

        values = custom_field_values
        saved_values = {}
        values.each_with_index do |value,i|
          saved_values[self.custom_values[i].custom_field_id] = value
        end

        p 'rollback_forward'
        #TODO Insere opção de habilitar ou nao rollback projeto
        if Setting.plugin_redmine_gestor_chamadas[:rollback_forwarding_config] != "assigned_to"
          journal_created_on = change_to_last_project()
          change_to_last_assigned(journal_created_on)
        else
          change_to_last_assigned(nil)
        end
        self.custom_field_values = saved_values
      end

      def change_to_last_project
        journal = self.journals.joins(:details).where(journal_details:{prop_key:'project_id'}).order('journal_details.id DESC').select("journals.created_on,journal_details.old_value").first
        return nil if journal.blank?

        if journal.old_value
          p 'change_to_last_project'
          self.project_id = journal.old_value
        end
        journal.created_on
      end

      def change_to_last_assigned(journal_created_on)
        p 'change_to_last_assigned'
        detail = nil
        if journal_created_on
          detail = self.journals.joins(:details).where(journal_details:{prop_key:'assigned_to_id'}).where('journals.created_on >= ?',journal_created_on).order('journal_details.id ASC').select("journal_details.old_value").first
        else
          detail = self.journals.joins(:details).where(journal_details:{prop_key:'assigned_to_id'}).order('journal_details.id ASC').select("journal_details.old_value").first
        end
        if !detail.blank?
          self.assigned_to_id = detail.old_value
        end
      end

      def increase_priority #Thriggered when changed mistaken_status
        return if Setting.plugin_redmine_gestor_chamadas[:copy_issue_when_forward] != "true" || Setting.plugin_redmine_gestor_chamadas[:increase_priority_forwarded] != "true"
        p 'increase_priority'
        change_priority_to(Setting.plugin_redmine_gestor_chamadas[:high_priority])
      end

      def add_satisfaction_survey_journal #Thriggered when changed status
        issue = self
        if issue.current_journal.nil?
          user = User.current
          issue.init_journal(user,"")
        end
        journal = issue.current_journal
        change_status  = issue.status_id_changed?
        return unless change_status== true && Setting.plugin_redmine_gestor_chamadas[:answered_status].to_i == issue.status_id &&  IssueRelation.where(:issue_to_id => issue.id, :relation_type => "copied_to").blank?
        host_url = Setting.protocol + '://'+Setting.host_name
        url = Rails.application.routes.url_helpers.new_satisfaction_survey_url(:host => host_url, :error => '0', :issue_id=> issue.id)
    		journal.notes+= "\n \n" + l(:answer_satisfaction_survey_message) + ": "+ url
      end

      def mark_as_answered_priority
        return if Setting.plugin_redmine_gestor_chamadas[:copy_issue_when_forward] != "true" || Setting.plugin_redmine_gestor_chamadas[:mistaken_notify] != "true" || Setting.plugin_redmine_gestor_chamadas[:enable_change_status_in_copy] == "true"
        p 'mark_as_answered_priority'
        change_priority_to(Setting.plugin_redmine_gestor_chamadas[:answered_priority])
      end

      def change_parent_status_if_children_answered
        return if !status.is_closed? || !(self.tracker_id.to_s.in? Setting.plugin_redmine_gestor_chamadas[:change_status_copy_trackers])
        parent_relation = self.relations.reject{|r| r.relation_type!="copied_to" || r.issue_to_id != self.id}.first
        if parent_relation.present?
          parent = Issue.find(parent_relation.issue_from_id)
          return if parent.status != IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:copied_status_to])
          systemuser = User.find(12379)
          parent.init_journal(systemuser)
          parent.status = IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:answered_status_to])
          parent.save(validate: false)
        end
      end

      def change_parent_status_if_copied
        if @copied_from.present? && (self.tracker_id.to_s.in? Setting.plugin_redmine_gestor_chamadas[:change_status_copy_trackers])
          @copied_from.init_journal(User.current)
          @copied_from.status = IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:copied_status_to])
          @copied_from.save(validate: false)
        end
      end

      def change_priority_to(priority_id)
        priority = IssuePriority.find(priority_id)
        relations_to.each do |relation_to|
          issue_from = relation_to.issue_from
          if issue_from.priority.id != Setting.plugin_redmine_gestor_chamadas[:high_priority].to_i
            issue_from.priority = priority
            @issue_from = issue_from
            issue_from.save(validate: false)
          end
        end
      end

      def archived?
        self.status == IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:archived_status])
      end

      # Returns true if user or current user is allowed to archive an issue
      def archivable?(user=User.current)
        return false if self.archived?
        if user.allowed_to?(:edit_issues, project) || user.allowed_to?(:add_issue_notes, project)
          archivable_statuses = IssueStatus.where(is_closed:true, archivable: true)
          if self.status.in? archivable_statuses
            return true if Setting.plugin_redmine_gestor_chamadas[:archive_with_comments_after_closed] == "true"

            #Verificar atualizacoes apos concluido
            closing_journal = Journal.includes(:details).where(journalized_id:self)
                .where(journal_details: {prop_key:'status_id',value: archivable_statuses}).order(:created_on).last
            if closing_journal and self.journals_after(closing_journal.id).size > 0
              return true
            else
              return false
            end
          end
        end
      end

      def archive(user, notes=nil)
        @user = user
        @new_journal = Journal.new(:journalized => self, :user => @user, :notes => notes)
        @new_journal.details << JournalDetail.new(:property => 'attr', :prop_key => 'status_id',:old_value => self.status_id, :value => Setting.plugin_redmine_gestor_chamadas[:archived_status])
        self.journals << @new_journal

        self.status_id = Setting.plugin_redmine_gestor_chamadas[:archived_status]
        self.save
      end

      def reopen_not_satisfied(user, notes, status_to)
        @user = user

        @new_journal = Journal.new(:journalized => self, :user => @user, :notes => notes)
        @new_journal.details << JournalDetail.new(:property => 'attr', :prop_key => 'status_id',:old_value => self.status_id, :value => status_to)
        self.journals << @new_journal

        self.status_id = status_to
        self.save(validate: false)
      end

      def show_satisfaction_survey?
        return false if !IssueRelation.where(:issue_to_id => self.id, :relation_type => "copied_to").blank?
        return false if Setting.plugin_redmine_gestor_chamadas[:enable_satisfaction_survey] != "true"
        return true if self.status_id == Setting.plugin_redmine_gestor_chamadas[:answered_status].to_i
      end

      def reopen_allowed?
        return true if Setting.plugin_redmine_gestor_chamadas[:trackers_reopen_disabled].blank?
        Setting.plugin_redmine_gestor_chamadas[:trackers_reopen_disabled].each do |tracker_id|
            return false if self.tracker_id == tracker_id.to_i
        end
        return true
      end

      def check_copy_to_same_project
        if self.project_id == @copied_from.project_id
          errors.add(:project_id, :forward_same_project)
        end
      end

      def editable_with_disabled_archived_edit?(user=User.current)
        editable_without_disabled_archived_edit?(user) && (user.admin? || Setting.plugin_redmine_gestor_chamadas[:disable_archived_edit].eql?("false") || self.status.id.to_s != Setting.plugin_redmine_gestor_chamadas[:archived_status] )
      end

      def attributes_editable_with_disabled_archived_edit?(user=User.current)
        attributes_editable_without_disabled_archived_edit?(user) && (user.admin? || Setting.plugin_redmine_gestor_chamadas[:disable_archived_edit].eql?("false") || self.status.id.to_s != Setting.plugin_redmine_gestor_chamadas[:archived_status] )
      end

      def cascade_priority
        priority = IssuePriority.find(priority_id)
        relations_to = self.relations.reject{|r| r.relation_type!="copied_to" || r.issue_from_id != self.id}

        relations_to.each do |r|
          i = r.issue_to
          if !i.status.is_closed?
            systemuser = User.find(12379)
            i.init_journal(systemuser)
            i.priority = priority
            i.save
          end
        end
      end

      def check_parent_is_closed
        parent_relation = self.relations.reject{|r| r.relation_type != "copied_to" || r.issue_to_id != self.id}.first
        if parent_relation.present?
          parent = Issue.find(parent_relation.issue_from_id)
          if parent.status.is_closed?
            errors.add(:base, l(:not_possible_to_update_because_parent_closed))
          end
        end
      end



    end
  end
end
