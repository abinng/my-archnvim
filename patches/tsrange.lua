local M = {}
local TSRange = {}
TSRange.__index = TSRange

local api = vim.api
local ts_utils = require "nvim-treesitter.ts_utils"
local parsers = require "nvim-treesitter.parsers"

local function get_byte_offset(buf, row, col)
  return api.nvim_buf_get_offset(buf, row) + vim.fn.byteidx(api.nvim_buf_get_lines(buf, row, row + 1, false)[1], col)
end

local function get_node_pos(node, is_end)
  if not node then return nil end
  if type(node) == "table" and not node.range and not node.start then
    node = is_end and node[#node] or node[1]
  end
  if node.range then
    local sr, sc, sb, er, ec, eb = node:range(true)
    return is_end and { er, ec, eb } or { sr, sc, sb }
  elseif is_end and node.end_ then
    return { node:end_() }
  elseif not is_end and node.start then
    return { node:start() }
  end
  return { 0, 0, 0 }
end

function TSRange.new(buf, start_row, start_col, end_row, end_col)
  return setmetatable({
    start_pos = { start_row, start_col, get_byte_offset(buf, start_row, start_col) },
    end_pos = { end_row, end_col, get_byte_offset(buf, end_row, end_col) },
    buf = buf,
    [1] = start_row,
    [2] = start_col,
    [3] = end_row,
    [4] = end_col,
  }, TSRange)
end

function TSRange.from_nodes(buf, start_node, end_node)
  TSRange.__index = TSRange
  local start_pos = start_node and get_node_pos(start_node, false) or get_node_pos(end_node, false)
  local end_pos = end_node and get_node_pos(end_node, true) or get_node_pos(start_node, true)
  return setmetatable({
    start_pos = { start_pos[1], start_pos[2], start_pos[3] },
    end_pos = { end_pos[1], end_pos[2], end_pos[3] },
    buf = buf,
    [1] = start_pos[1],
    [2] = start_pos[2],
    [3] = end_pos[1],
    [4] = end_pos[2],
  }, TSRange)
end

function TSRange.from_table(buf, range)
  return setmetatable({
    start_pos = { range[1], range[2], get_byte_offset(buf, range[1], range[2]) },
    end_pos = { range[3], range[4], get_byte_offset(buf, range[3], range[4]) },
    buf = buf,
    [1] = range[1],
    [2] = range[2],
    [3] = range[3],
    [4] = range[4],
  }, TSRange)
end

function TSRange:parent()
  local root_lang_tree = parsers.get_parser(self.buf)
  local root = ts_utils.get_root_for_position(self[1], self[2], root_lang_tree)

  return root
      and root:named_descendant_for_range(self.start_pos[1], self.start_pos[2], self.end_pos[1], self.end_pos[2])
    or nil
end

function TSRange:field() end

function TSRange:child_count()
  return #self:collect_children()
end

function TSRange:named_child_count()
  return #self:collect_children(function(c)
    return c:named()
  end)
end

function TSRange:iter_children()
  local raw_iterator = self:parent().iter_children()
  return function()
    while true do
      local node = raw_iterator()
      if not node then
        return
      end
      local start_byte, end_byte
      if node.range then
        local _, _, sb, _, _, eb = node:range(true)
        start_byte, end_byte = sb, eb
      else
        local _, _, sb = node:start()
        local _, _, eb = node:end_()
        start_byte, end_byte = sb, eb
      end
      if start_byte and end_byte and start_byte >= self.start_pos[3] and end_byte <= self.end_pos[3] then
        return node
      end
    end
  end
end

function TSRange:collect_children(filter_fun)
  local children = {}
  for _, c in self:iter_children() do
    if not filter_fun or filter_fun(c) then
      table.insert(children, c)
    end
  end
  return children
end

function TSRange:child(index)
  return self:collect_children()[index + 1]
end

function TSRange:named_child(index)
  return self:collect_children(function(c)
    return c.named()
  end)[index + 1]
end

function TSRange:start()
  return unpack(self.start_pos)
end

function TSRange:end_()
  return unpack(self.end_pos)
end

function TSRange:range()
  return self.start_pos[1], self.start_pos[2], self.end_pos[1], self.end_pos[2]
end

function TSRange:type()
  return "nvim-treesitter-range"
end

function TSRange:symbol()
  return -1
end

function TSRange:named()
  return false
end

function TSRange:missing()
  return false
end

function TSRange:has_error()
  return #self:collect_children(function(c)
    return c:has_error()
  end) > 0 and true or false
end

function TSRange:sexpr()
  return table.concat(
    vim.tbl_map(function(c)
      return c:sexpr()
    end, self:collect_children()),
    " "
  )
end

M.TSRange = TSRange
return M
