local api = vim.api

local parsers = require "nvim-treesitter.parsers"
local queries = require "nvim-treesitter.query"
local ts_utils = require "nvim-treesitter.ts_utils"
local ts = require "nvim-treesitter.compat"

local M = {}

if not unpack then
  unpack = table.unpack
end

local function unwrap_node(n)
  if not n then return nil end
  if type(n) == "table" and not n.range then
    return n[1] or n[#n]
  end
  return n
end

local function get_node_coords(n)
  n = unwrap_node(n)
  if not n or not n.range then return nil end
  local sr, sc, er, ec = n:range()
  if not sr or not sc or not er or not ec then return nil end

  local sb, eb
  local ok, b_start, b_end = pcall(function() return n:byte_range() end)
  if ok and b_start and b_end then
    sb, eb = b_start, b_end
  else
    sb = sr * 100000 + sc
    eb = er * 100000 + ec
  end
  local len = eb - sb
  return { sr = sr, sc = sc, sb = sb, er = er, ec = ec, eb = eb, len = len, node = n }
end

local function _cmp_pos(a_row, a_col, b_row, b_col)
  if a_row == b_row then
    if a_col > b_col then
      return 1
    elseif a_col < b_col then
      return -1
    else
      return 0
    end
  elseif a_row > b_row then
    return 1
  end
  return -1
end

local cmp_pos = {
  gt = function(...) return _cmp_pos(...) == 1 end,
  lt = function(...) return _cmp_pos(...) == -1 end,
}

function M.node_contains(node, range)
  node = unwrap_node(node)
  if not node or not node.range then return false end
  local srow_1, scol_1, erow_1, ecol_1 = node:range()
  local srow_2, scol_2, erow_2, ecol_2 = unpack(range)
  if cmp_pos.gt(srow_1, scol_1, srow_2, scol_2) then return false end
  if cmp_pos.lt(erow_1, ecol_1, erow_2, ecol_2) then return false end
  return true
end

function M.make_query_strings_table(query_strings)
  return type(query_strings) == "string" and { query_strings } or query_strings
end

function M.get_query_strings_from_regex(query_strings_regex, query_group, lang)
  query_strings_regex = M.make_query_strings_table(query_strings_regex)
  query_group = query_group or "textobjects"
  lang = lang or parsers.get_buf_lang(0)
  local available_textobjects = M.available_textobjects(lang, query_group)
  local query_strings = {}
  for _, query_string_regex in ipairs(query_strings_regex) do
    for _, available_textobject in ipairs(available_textobjects) do
      if string.match("@" .. available_textobject, query_string_regex) then
        table.insert(query_strings, "@" .. available_textobject)
      end
    end
  end
  return query_strings
end

function M.available_textobjects(lang, query_group)
  lang = lang or parsers.get_buf_lang()
  query_group = query_group or "textobjects"
  local parsed_queries = ts.get_query(lang, query_group)
  if not parsed_queries then return {} end
  local found_textobjects = parsed_queries.captures or {}
  for _, p in pairs(parsed_queries.info.patterns) do
    for _, q in ipairs(p) do
      local query, arg1 = unpack(q)
      if query == "make-range!" and not vim.tbl_contains(found_textobjects, arg1) then
        table.insert(found_textobjects, arg1)
      end
    end
  end
  return found_textobjects
end

local function best_match_at_point(matches, row, col, opts)
  local match_length
  local smallest_range
  local earliest_start

  local lookahead_match_length
  local lookahead_largest_range
  local lookahead_earliest_start
  local lookbehind_match_length
  local lookbehind_largest_range
  local lookbehind_earliest_start

  for _, m in pairs(matches) do
    local info = get_node_coords(m.node)
    if info then
      m.node = info.node
      local is_inside = (info.sr < row or (info.sr == row and info.sc <= col))
        and (info.er > row or (info.er == row and info.ec >= col))

      if is_inside then
        local length = info.len
        if not match_length or length < match_length then
          smallest_range = m
          match_length = length
        end
        if match_length and length == match_length then
          local s_info = m.start and get_node_coords(m.start.node)
          local start_byte = s_info and s_info.sb or info.sb
          if not earliest_start or start_byte < earliest_start then
            smallest_range = m
            match_length = length
            earliest_start = start_byte
          end
        end
      elseif opts.lookahead then
        local start_line, start_col, start_byte = info.sr, info.sc, info.sb
        local length = info.len
        if start_line > row or (start_line == row and start_col > col) then
          if
            not lookahead_earliest_start
            or lookahead_earliest_start > start_byte
            or (lookahead_earliest_start == start_byte and lookahead_match_length < length)
          then
            lookahead_match_length = length
            lookahead_largest_range = m
            lookahead_earliest_start = start_byte
          end
        end
      elseif opts.lookbehind then
        local start_line, start_col, start_byte = info.sr, info.sc, info.sb
        local length = info.len
        if start_line < row or (start_line == row and start_col < col) then
          if
            not lookbehind_earliest_start
            or lookbehind_earliest_start < start_byte
            or (lookbehind_earliest_start == start_byte and lookbehind_match_length > length)
          then
            lookbehind_match_length = length
            lookbehind_largest_range = m
            lookbehind_earliest_start = start_byte
          end
        end
      end
    end
  end

  local get_range = function(match)
    if match.metadata ~= nil and match.metadata.range then
      return match.metadata.range
    end
    local node = unwrap_node(match.node)
    if node and node.range then
      local sr, sc, er, ec = node:range()
      return { sr, sc, er, ec }
    end
    return { 0, 0, 0, 0 }
  end

  if smallest_range then
    if smallest_range.start then
      local start_range = get_range(smallest_range.start)
      local node_range = get_range(smallest_range)
      return { start_range[1], start_range[2], node_range[3], node_range[4] }, smallest_range.node
    else
      return get_range(smallest_range), smallest_range.node
    end
  elseif lookahead_largest_range then
    return get_range(lookahead_largest_range), lookahead_largest_range.node
  elseif lookbehind_largest_range then
    return get_range(lookbehind_largest_range), lookbehind_largest_range.node
  end
end

function M.textobject_at_point(query_string, query_group, pos, bufnr, opts)
  query_group = query_group or "textobjects"
  opts = opts or {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local lang = parsers.get_buf_lang(bufnr)
  if not lang then return end

  local row, col = unpack(pos or vim.api.nvim_win_get_cursor(0))
  row = row - 1

  if not string.match(query_string, "^@.*") then
    error 'Captures must start with "@"'
    return
  end

  local matches = queries.get_capture_matches_recursively(bufnr, query_string, query_group)
  if string.match(query_string, "^@.*%.outer$") then
    local range, node = best_match_at_point(matches, row, col, opts)
    return bufnr, range, unwrap_node(node)
  else
    local query_string_outer = string.gsub(query_string, "%..*", ".outer")
    if query_string_outer == query_string then
      query_string_outer = query_string .. ".outer"
    end

    local matches_outer = queries.get_capture_matches_recursively(bufnr, query_string_outer, query_group)
    if #matches_outer == 0 then
      local range, node = best_match_at_point(matches, row, col, opts)
      return bufnr, range, unwrap_node(node)
    end

    local range_outer, node_outer = best_match_at_point(matches_outer, row, col, {})
    if range_outer == nil then
      local range, node = best_match_at_point(matches, row, col, opts)
      return bufnr, range, unwrap_node(node)
    end

    local matches_within_outer = {}
    for _, match in ipairs(matches) do
      local mnode = unwrap_node(match.node)
      if mnode and mnode.range and M.node_contains(node_outer, { mnode:range() }) then
        table.insert(matches_within_outer, match)
      end
    end
    if #matches_within_outer == 0 then
      local range, node = best_match_at_point(matches, row, col, opts)
      return bufnr, range, unwrap_node(node)
    else
      local range, node = best_match_at_point(matches_within_outer, row, col, opts)
      if range ~= nil then
        return bufnr, range, unwrap_node(node)
      else
        range, node = best_match_at_point(matches_within_outer, range_outer[1], range_outer[2], { lookahead = true })
        return bufnr, range, unwrap_node(node)
      end
    end
  end
end

function M.get_adjacent(forward, node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
  query_group = query_group or "textobjects"
  local fn = forward and M.next_textobject or M.previous_textobject
  return fn(node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
end

function M.next_textobject(node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
  query_group = query_group or "textobjects"
  local node = unwrap_node(node or vim.treesitter.get_node_at_cursor())
  local bufnr = bufnr or api.nvim_get_current_buf()
  local n_info = get_node_coords(node)
  if not n_info then return end

  local node_end = n_info.eb
  local search_start = overlapping_range_ok and (n_info.sb + 1) or n_info.eb

  local function filter_function(match)
    local mnode = unwrap_node(match.node)
    local m_info = get_node_coords(mnode)
    if not m_info or mnode == node then return end
    if not same_parent or node:parent() == mnode:parent() then
      return m_info.sb >= search_start and m_info.eb >= node_end
    end
  end

  local function scoring_function(match)
    local mnode = unwrap_node(match.node)
    local m_info = get_node_coords(mnode)
    return m_info and -m_info.sb or 0
  end

  local next_node = queries.find_best_match(bufnr, query_string, query_group, filter_function, scoring_function)
  if next_node then return unwrap_node(next_node.node), next_node.metadata end
end

function M.previous_textobject(node, query_string, query_group, same_parent, overlapping_range_ok, bufnr)
  query_group = query_group or "textobjects"
  local node = unwrap_node(node or vim.treesitter.get_node_at_cursor())
  local bufnr = bufnr or api.nvim_get_current_buf()
  local n_info = get_node_coords(node)
  if not n_info then return end

  local node_start = n_info.sb
  local search_end = overlapping_range_ok and (n_info.eb - 1) or n_info.sb

  local function filter_function(match)
    local mnode = unwrap_node(match.node)
    local m_info = get_node_coords(mnode)
    if not m_info or mnode == node then return end
    if not same_parent or node:parent() == mnode:parent() then
      return m_info.eb <= search_end and m_info.sb < node_start
    end
  end

  local function scoring_function(match)
    local mnode = unwrap_node(match.node)
    local m_info = get_node_coords(mnode)
    return m_info and m_info.eb or 0
  end

  local previous_node = queries.find_best_match(bufnr, query_string, query_group, filter_function, scoring_function)
  if previous_node then return unwrap_node(previous_node.node), previous_node.metadata end
end

return M
