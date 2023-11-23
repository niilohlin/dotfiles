
function vim.getVisualSelection()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow - 1, cscol - 1, cerow - 1, cecol
  else
    return cerow - 1, cecol - 1, csrow - 1, cscol
  end
end
-- function vim.getVisualSelection()
-- 	vim.cmd('noau normal! "vy"')
-- 	local text = vim.fn.getreg('v')
-- 	vim.fn.setreg('v', {})

-- 	text = string.gsub(text, "\n", "")
-- 	if #text > 0 then
-- 		return text
-- 	else
-- 		return ''
-- 	end
-- end
