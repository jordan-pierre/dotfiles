--- @sync entry
-- Toggle different views on/off: parent, current, preview (uses rt.mgr.ratio and ya.emit like yazi-rs/plugins toggle-pane)
local function entry(st, job)
  local R = rt.mgr.ratio
  local args = job.args or job
  local action = args[1] or args.args
  if not action then
    return
  end

  -- Persist config ratios and current state (from config when first run)
  st.parent = st.parent or R.parent
  st.current = st.current or R.current
  st.preview = st.preview or R.preview

  if action == "parent" then
    st.parent = (st.parent > 0) and 0 or R.parent
  elseif action == "current" then
    st.current = (st.current > 0) and 0 or R.current
  elseif action == "preview" then
    st.preview = (st.preview > 0) and 0 or R.preview
  else
    return
  end

  if not st.old then
    st.old = Tab.layout
  end
  Tab.layout = function(self)
    local all = st.parent + st.current + st.preview
    self._chunks = ui.Layout()
      :direction(ui.Layout.HORIZONTAL)
      :constraints({
        ui.Constraint.Ratio(st.parent, all),
        ui.Constraint.Ratio(st.current, all),
        ui.Constraint.Ratio(st.preview, all),
      })
      :split(self._area)
  end
  ya.emit("app:resize", {})
end

return { entry = entry }
