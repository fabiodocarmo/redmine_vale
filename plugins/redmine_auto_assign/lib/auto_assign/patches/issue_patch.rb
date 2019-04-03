module AutoAssign
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          before_save :auto_assign
          after_save :save_round_redistribute
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def auto_assign
          self.watcher_user_ids = fetch_watcher_user_ids
          if @atribuicao_automatica = AtribuicaoAutomatica.find_by_issue(self).where('redistribute not in (?) or redistribute is null', AtribuicaoAutomatica::WATCHER_REDISTRIBUTE_TYPE).first
            if @atribuicao_automatica.redistribute.blank?
              self.assigned_to_id = @atribuicao_automatica.assign_group.id
            else
              self.assigned_to_id = @atribuicao_automatica.send("#{@atribuicao_automatica.redistribute}_redistribute", self)
            end
          end
        end

        def save_round_redistribute
          return unless @atribuicao_automatica.try(:redistribute).try(:to_sym) == :round

          group = @atribuicao_automatica.assign_group
          round_redistribute = RoundRedistribute.where(group_id: group.id).first_or_initialize
          round_redistribute.times += 1
          round_redistribute.save!
        end

        private

        def fetch_watcher_user_ids
          (self.watcher_user_ids || []) | AtribuicaoAutomatica.find_by_issue(self)
                                        .where(redistribute: AtribuicaoAutomatica::WATCHER_REDISTRIBUTE_TYPE)
                                        .map { |aa| aa.send("#{aa.redistribute}_redistribute", self) }.flatten
        end
      end
    end
  end
end
