local kiroku = {}

local config = {
	home = os.getenv("HOME") .. "/kiroku",
	template = [[
---
title:
tags:
	- "#your-tag"
---

## References

## Backlinks

<!-- external links -->

]],
	file = {
		pattern = function()
			return os.date("%Y%m%d%H%M")
		end,
		extention = '.md',
		type = 'markdown'
	}
}

local function get_title_frontmatter(filename)
	local file = io.open(filename, "r")
	if file == nil then
		return ""
	end
	local title = ""
	if file then
		local frontmatter = true
		local frontmatter_line_count = 0
		while frontmatter do
			local line = file:read("*l")
			if line == nil then
				break
			end
			if line == "---" then
				frontmatter_line_count = frontmatter_line_count + 1
			end
			if frontmatter_line_count >= 2 then
				frontmatter = false
			end
			if string.sub(line, 1, 6) == "title:" then
				title = string.sub(line, 8, string.len(line))
			end
		end
	end
	file:close()
	return title
end

function kiroku.format_cmp(entry, vim_item)
	-- local kiroku_home = os.getenv("HOME") .. "/kiroku-copy"
	local cwd = vim.fn.getcwd()
	local is_markdown = entry.context.filetype == "markdown"

	if config.home == cwd and is_markdown and entry.completion_item.detail ~= nil then
		-- get the front matter
		local title = get_title_frontmatter(entry.completion_item.detail)
		if title:len() ~= 0 then
			title = string.format("(%s)", title)
		end
		local menu = ""
		if vim_item.menu ~= nil then
			menu = vim_item.menu
		end
		vim_item.menu = menu .. title
	end
	return vim_item
end

function kiroku.new_kiroku()
	local current_time = config.file.pattern()
	local file_name = current_time .. config.file.extention
	local isEmpty = vim.api.nvim_buf_line_count(0) <= 1 and vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == ""
	if isEmpty == false then
		vim.cmd('enew')
	end

	vim.api.nvim_buf_set_name(0, file_name)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(config.template, "\n"))
	-- Set the file type to Markdown
	vim.api.nvim_set_option_value("filetype", config.file.type, { buf = 0 })

	print("A new kiroku created: " .. file_name)
end

function kiroku.insert_title()
	local vstart = vim.fn.getpos("'<")
	local vend = vim.fn.getpos("'>")
	local linestart = vstart[2]
	local lineend = vend[2]
	if linestart <= lineend then
		linestart = linestart - 1
	elseif linestart == lineend then
		linestart = linestart - 1
		lineend = linestart
	end
	local currbuf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(currbuf, linestart, lineend, true)

	for i, v in ipairs(lines) do
		local extractedStrings = {}

		for match in v:gmatch("%[%[(.-)%]%]") do
			table.insert(extractedStrings, match)
		end

		local replacement_line = ""
		for _, filename in ipairs(extractedStrings) do
			local title = get_title_frontmatter(filename .. ".md")
			local replacement_token = string.format("[[%s]] %s", filename, title)
			local pattern = "%[%[" .. filename .. "%]%]"
			replacement_line = v:gsub(pattern, replacement_token)
		end
		vim.api.nvim_buf_set_text(currbuf, linestart + i - 1, 0, linestart + i - 1, #v, { replacement_line })
	end
end

-- keymapping
vim.keymap.set("v", "<leader>ki", function() kiroku.insert_title() end, { desc = '[K]iroku [I]nsert title' })
vim.keymap.set("n", "<leader>kn", function() kiroku.new_kiroku() end, { desc = '[K]iroku [N]ew document' })

-- create command
vim.api.nvim_create_user_command('Kiroku', function(args)
	if args.fargs[1] == 'new' then
		kiroku.new_kiroku()
	end
	if args.fargs[1] == "insertTitle" then
		kiroku.insert_title()
	end
end, {
	range = true,
	nargs = '+'
})

return kiroku
