local m = {}

function SnakeCase(str)
  return str:gsub('([a-z])([A-Z])', '%1_%2'):lower()
end

function m.GetYamlPathUnderCursor()
  local cursor_line = vim.fn.line '.'
  local key_path = {}

  -- Get the current indentation level
  local current_indent = #vim.fn.getline(cursor_line):match '^%s*'

  -- Function to extract the key from a line
  local function get_key_from_line(line)
    return line:match '^%s*([%w_.-]+):'
  end

  -- Start from the current line and go upwards to build the path
  for i = cursor_line, 1, -1 do
    local line = vim.fn.getline(i)
    local indent = #line:match '^%s*'

    if indent < current_indent and get_key_from_line(line) then
      table.insert(key_path, 1, get_key_from_line(line))
      current_indent = indent
    elseif indent == current_indent and i == cursor_line then
      table.insert(key_path, get_key_from_line(line))
    end
  end

  -- Combine the key path with a dot
  local path = table.concat(key_path, '.')

  -- if last two characters are "de" or "en", remove them
  if path:sub(-2) == 'de' or path:sub(-2) == 'en' then
    path = path:sub(1, -4)
  end

  return path
end

-- function m.GetYamlPathUnderCursor()
--   local cursor_line = vim.fn.line '.' -- Get current line number
--   local cursor_col = vim.fn.col '.' -- Get current column number
--
--   local key_path = {}
--   local current_indent = nil
--
--   -- Iterate backward to find all parent keys
--   for i = cursor_line, 1, -1 do
--     local line = vim.fn.getline(i)
--
--     -- Check if the line is a key-value pair or just a key
--     local key, rest = line:match '^%s*([%w_-]+):%s*(.*)'
--
--     if key then
--       -- Get the indentation level (spaces at the beginning)
--       local indent = #line:match '^%s*'
--
--       -- If current_indent is nil, it means we are at the first key
--       if not current_indent or indent < current_indent then
--         table.insert(key_path, 1, key)
--         current_indent = indent
--       end
--     end
--   end
--
--   -- Combine the key path with a dot
--   local path = table.concat(key_path, '.')
--
--   -- vim.api.nvim_echo({ { 'YAML Path: ' .. path, 'Normal' } }, false, {})
--
--   return path
-- end
--
function m.GetTranslationFilePrefix()
  local path = vim.api.nvim_buf_get_name(0)

  -- check that the path contains a directory called /pages/ and that the file name is "translations.yaml"
  if not path:match '/pages/' or not path:match 'translations.yaml$' then
    print 'This is not a translations.yaml file in a /pages/ directory.'
    return
  end

  -- print('Path1: ' .. path)

  -- get the path between /pages/ and /translations.yaml
  path = path:match '/pages/(.-)/translations.yaml$'

  -- print('Path2: ' .. path)
  if not path:match '/' then
    return '@' .. SnakeCase(path) .. ':'
  end

  -- get the bundle, which is the first part of the path
  local bundle = SnakeCase(path:match '(.-)/')

  -- take all remaining parts of the path
  local parts = vim.fn.split(path, '/')
  table.remove(parts, 1)

  -- convert the other parts to snake_case
  for i, part in ipairs(parts) do
    parts[i] = SnakeCase(part)
  end

  -- join the parts with a dot
  local key = table.concat(parts, '.')

  -- copy the key to the default register
  local prefix = '@' .. bundle .. ':' .. key

  return prefix
end

function GetTranslationKeyUnderCursor()
  local prefix = m.GetTranslationFilePrefix()
  local key_path = m.GetYamlPathUnderCursor()

  print('prefix: ' .. prefix)
  print('key path: ' .. key_path)

  if not prefix or not key_path then
    print "Couldn't get the translation file prefix or the key path."
    return
  end

  local sep = '.'
  if prefix:match ':$' then
    sep = ''
  end

  return prefix .. sep .. key_path
end

function m.CopyTranslationKeyUnderCursor()
  local key = GetTranslationKeyUnderCursor()

  vim.fn.setreg('', key)
  print('Copied key to register: ' .. key)
end

function m.CopyTranslationKeyUnderCursorWithCall()
  local key = GetTranslationKeyUnderCursor()
  local call = '{{ $t("' .. key .. '") }}'

  vim.fn.setreg('', call)
  print('Copied call to register: ' .. call)
end

function m.CopyTranslationFilePrefix()
  vim.fn.setreg('', m.GetTranslationFilePrefix())
end

return m
