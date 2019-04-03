module Portal
  module Hooks
    class LeftBlocksHook < Redmine::Hook::ViewListener
      render_on :view_welcome_index_left, partial: 'blocks/left_block.html'
    end
  end
end
