local ts_utils = require "nvim-treesitter.ts_utils"
local shared = require "nvim-treesitter.textobjects.shared"
local attach = require "nvim-treesitter.textobjects.attach"

local M = {}

local function unwrap_node(n)
  if not n then return nil end
  if type(n) == "table" and not n.range then
    return n[1] or n[#n]
  end
  return n
end

local function swap_textobject(query_strings_regex, query_group, direction)
  query_strings_regex = shared.make_query_strings_table(query_strings_regex)
  query_group = query_group or "textobjects"

  local query_strings = shared.get_query_strings_from_regex(query_strings_regex, query_group)

  local bufnr, textobject_range, node, query_string
  for _, query_string_iter in ipairs(query_strings) do
    bufnr, textobject_range, node = shared.textobject_at_point(query_string_iter, query_group)
    if node then
      query_string = query_string_iter
      break
    end
  end
  if not query_string or not textobject_range then
    return
  end

  local step = direction > 0 and 1 or -1
  local overlapping_range_ok = false
  local same_parent = true
  for _ = 1, math.abs(direction), step do
    local forward = direction > 0
    local adjacent, metadata =
      shared.get_adjacent(forward, node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
    
    local target = metadata and metadata.range or unwrap_node(adjacent)
    -- 边界拦截：如果不存在相邻语句（例如到顶或到底），直接静默返回，不抛异常
    if not target or (type(target) == "table" and not target.range and #target == 0) then
      return
    end

    ts_utils.swap_nodes(textobject_range, target, bufnr, "yes, set cursor!")
  end
end

function M.swap_next(query_strings_regex, query_group)
  swap_textobject(query_strings_regex, query_group, 1)
end

function M.swap_previous(query_strings_regex, query_group)
  swap_textobject(query_strings_regex, query_group, -1)
end

local normal_mode_functions = { "swap_next", "swap_previous" }

M.attach = attach.make_attach(normal_mode_functions, "swap", "n", { dot_repeatable = true })
M.detach = attach.make_detach "swap"

M.commands = {
  TSTextobjectSwapNext = {
    run = M.swap_next,
    args = {
      "-nargs=1",
      "-complete=custom,nvim_treesitter_textobjects#available_textobjects",
    },
  },
  TSTextobjectSwapPrevious = {
    run = M.swap_previous,
    args = {
      "-nargs=1",
      "-complete=custom,nvim_treesitter_textobjects#available_textobjects",
    },
  },
}

return M
