local source = {}

source.new = function()
    return setmetatable({
        running_job_id = 0,
        timer = vim.loop.new_timer(),
    }, { __index = source })
end

source.complete = function(self, request, callback)
    local q = string.sub(request.context.cursor_before_line, request.offset)
    local pattern = request.option.pattern or "[a-zA-Z_-]+"
    local additional_arguments = request.option.additional_arguments or ""
    local context_before = request.option.context_before or 1
    local context_after = request.option.context_after or 3
    local quote = "'"
    if vim.o.shell == "cmd.exe" then
        quote = '"'
    end
    local seen = {}
    local items = {}
    local context = {}
    local documentation_to_add = 0

    local function on_event(job_id, data, event)
        if event == "stdout" then
            for _, entry in ipairs(data) do
                if entry ~= "" then
                    local ok, result = pcall(vim.json.decode, entry)
                    if not ok or result.type == "end" then
                        context = {}
                        documentation_to_add = 0
                    elseif result.type == "context" then
                        local documentation = result.data.lines.text:gsub("\n", "")
                        table.insert(context, documentation)
                        if documentation_to_add > 0 then
                            local d = items[#items].documentation
                            table.insert(d, documentation)
                            documentation_to_add = documentation_to_add - 1

                            if documentation_to_add == 0 then
                                local min_indent = 1e309
                                for i = 4, #d, 1 do
                                    if d[i] ~= "" then
                                        local _, indent = string.find(d[i], "^%s+")
                                        min_indent = math.min(min_indent, indent or 0)
                                    end
                                end
                                for i = 4, #d, 1 do
                                    d[i] = d[i]:sub(min_indent)
                                end
                                table.insert(d, "```")
                            end
                        end
                    elseif result.type == "match" then
                        local label = result.data.submatches[1].match.text
                        if label and not seen[label] then
                            local documentation = { result.data.path.text, "", "```" }
                            for i = context_before, 0, -1 do
                                table.insert(documentation, context[i])
                            end
                            local match_line = result.data.lines.text:gsub("\n", "") .. "  <--"
                            table.insert(documentation, match_line)
                            table.insert(items, {
                                label = label,
                                documentation = documentation,
                            })
                            documentation_to_add = context_after
                            seen[label] = true
                        end
                    end
                end
            end
            callback { items = items, isIncomplete = true }
        end

        if event == "stderr" and request.option.debug then
            vim.cmd "echohl Error"
            vim.cmd('echomsg "' .. table.concat(data, "") .. '"')
            vim.cmd "echohl None"
        end

        if event == "exit" then
            callback { items = items, isIncomplete = false }
        end
    end

    self.timer:stop()
    self.timer:start(
        request.option.debounce or 100,
        0,
        vim.schedule_wrap(function()
            vim.fn.jobstop(self.running_job_id)
            self.running_job_id = vim.fn.jobstart(
                string.format(
                    "rg --heading --json --word-regexp -B %d -A %d --color never %s %s%s%s%s .",
                    context_before,
                    context_after,
                    additional_arguments,
                    quote,
                    q,
                    pattern,
                    quote
                ),
                {
                    on_stderr = on_event,
                    on_stdout = on_event,
                    on_exit = on_event,
                    cwd = request.option.cwd or vim.fn.getcwd(),
                }
            )
        end)
    )
end

return source
