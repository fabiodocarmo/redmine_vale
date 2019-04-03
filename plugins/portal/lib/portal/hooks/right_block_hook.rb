module Portal
  module Hooks
    class RightBlocksHook < Redmine::Hook::ViewListener
      render_on :view_welcome_index_right, partial: 'blocks/right_block.html'
    end
  end
end
