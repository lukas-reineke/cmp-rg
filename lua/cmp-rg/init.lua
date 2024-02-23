require "cmp-rg.types"

local Process = require "cmp-rg.process"
local uv = vim.uv or vim.loop

local function show_error(msg)
    vim.notify("[cmp-rg] " .. msg, vim.log.levels.ERROR)
end

---@class Source
---@field public process table
---@field public timer any
local source = {}

source.new = function()
    local timer = uv.new_timer()
    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            if timer and not timer:is_closing() then
                timer:stop()
                timer:close()
            end
        end,
    })
    return setmetatable({
        timer = timer,
    }, { __index = source })
end

source.complete = function(self, request, callback)
    local q = string.sub(request.context.cursor_before_line, request.offset)
    local pattern = request.option.pattern or "[\\w_-]+"
    local additional_arguments = request.option.additional_arguments or {}
    if type(additional_arguments) == "string" then
        show_error('Now additional_arguments must be an array of string')
        additional_arguments = {}
    end
    local context_before = request.option.context_before or 1
    local context_after = request.option.context_after or 3
    local seen = {}
    local items = {}
    local chunk_size = 5

    local function on_event(data, event)
        if event == "stdout" then
            ---@type (string|rg.Message)[]
            local messages = data

            --- Get a message that has `data.lines.text`.
            --- If message is not yet decoded, decode it and update `messages` table.
            --- `\n` at the end of `data.lines.text` is removed.
            ---@param index number
            ---@return rg.Message|nil
            local function get_message_with_lines(index)
                if index < 1 then
                    return nil
                end
                local m = messages[index]
                if not m then
                    return nil
                end
                if type(m) == "string" then
                    local ok, decoded = pcall(vim.json.decode, m)
                    if not ok then
                        return nil
                    end
                    m, messages[index] = decoded, decoded
                end
                if m.type ~= "match" and m.type ~= "context" then
                    return nil
                end
                if not m.data.lines.text then
                    return nil
                end
                m.data.lines.text = m.data.lines.text:gsub("\n", "")
                return m
            end

            for current = 1, #data, 1 do
                local message = get_message_with_lines(current)
                if message and message.type == "match" then
                    local label = message.data.submatches[1].match.text
                    if label and not seen[label] then
                        local path = message.data.path.text
                        local doc_lines = { path, "", "```" }
                        local doc_body = {}
                        if context_before > 0 then
                            for j = current - context_before, current - 1, 1 do
                                local before = get_message_with_lines(j)
                                if before then
                                    table.insert(doc_body, before.data.lines.text)
                                end
                            end
                        end
                        table.insert(doc_body, message.data.lines.text .. " <--")
                        if context_after > 0 then
                            for k = current + 1, current + context_after, 1 do
                                local after = get_message_with_lines(k)
                                if after then
                                    table.insert(doc_body, after.data.lines.text)
                                end
                            end
                        end

                        -- shallow indent
                        local min_indent = math.huge
                        for _, line in ipairs(doc_body) do
                            local _, indent = string.find(line, "^%s+")
                            min_indent = math.min(min_indent, indent or math.huge)
                        end
                        for _, line in ipairs(doc_body) do
                            table.insert(doc_lines, line:sub(min_indent))
                        end

                        table.insert(doc_lines, "```")
                        local documentation = {
                            value = table.concat(doc_lines, "\n"),
                            kind = "markdown",
                        }
                        table.insert(items, {
                            label = label,
                            documentation = documentation,
                        })
                        seen[label] = true
                    end
                end
            end

            if request.max_item_count ~= nil and #items >= request.max_item_count then
                self.process:kill()
                callback { items = items, isIncomplete = false }
                return
            end

            if #items - chunk_size >= chunk_size then
                chunk_size = chunk_size * 2
                callback { items = items, isIncomplete = true }
            end
        end

        if event == "stderr" and request.option.debug then
            show_error(table.concat(data, ""))
        end

        if event == "exit" then
            callback { items = items, isIncomplete = false }
        end
    end

    self.timer:stop()
    self.timer:start(request.option.debounce or 100, 0, function()
        if self.process then
            self.process:kill()
        end
        local args = {
            "--heading",
            "--json",
            "--word-regexp",
            "-B",
            tostring(context_before),
            "-A",
            tostring(context_after),
            "--color",
            "never",
        }
        if #additional_arguments > 0 then
            for _, v in ipairs(additional_arguments) do
                table.insert(args, v)
            end
        end
        table.insert(args,q .. pattern)
        table.insert(args,".")
        self.process = Process.new("rg", args, on_event, { cwd = request.option.cwd }):run()
    end)
end

return source
