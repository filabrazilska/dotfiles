local wezterm = require 'wezterm';
local config = {}

local function get_process(tab)
  if not tab.active_pane or tab.active_pane.foreground_process_name == '' then
    return nil
  end

  local process_name = string.gsub(tab.active_pane.foreground_process_name, '(.*[/\\])(.*)', '%2')
  -- if string.find(process_name, 'kubectl') then
  --   process_name = 'kubectl'
  -- end

  return string.format('%s', process_name)
end

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local cwd = string.gsub(pane.current_working_dir.path, "(.*)/([^/]*)/$", "%2")
  local process = get_process(tab)
  if process == "bash" then
    return string.format('bash (%s)', cwd)
  else
    return pane.get_title()
  end
  -- local title = pane.get_title() or process and string.format('%s (%s) ', process, cwd) or ' [?] '

  -- return title
end) 

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'Builtin Solarized Light'
config.colors = {
  quick_select_label_bg = { Color = 'peru' },
  quick_select_label_fg = { Color = '#ffffff' },
  quick_select_match_bg = { AnsiColor = 'Navy' },
  quick_select_match_fg = { Color = '#ffffff' },
}
-- config.font = wezterm.font 'Inconsolata Nerd Font'
config.font = wezterm.font 'Fira Code'
config.font_size = 9.0
config.adjust_window_size_when_changing_font_size = false

-- Use the defaults as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()

config.hide_tab_bar_if_only_one_tab = true
config.enable_scroll_bar = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.selection_word_boundary = " \t{}[]()\"'`,;:"

return config
