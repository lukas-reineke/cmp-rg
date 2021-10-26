local source = {}

source.new = function()
    return setmetatable({}, { __index = source })
end

source.complete = function(self, request, callback)
    local q = string.sub(request.context.cursor_before_line, request.offset)
    local pattern = request.option.pattern or "[a-zA-Z_-]+"
    local additional_arguments = request.option.additional_arguments or ""
    local seen = {}
    local items = {}

    local function on_event(job_id, data, event)
        if event == "stdout" then
            for _, label in ipairs(data) do
                if not seen[label] then
                    table.insert(items, { label = label })
                    seen[label] = true
                end
            end
            callback { items = items, isIncomplete = true }
        end

        if event == "stderr" then
            vim.cmd "echohl Error"
            vim.cmd('echomsg "' .. table.concat(data, "") .. '"')
            vim.cmd "echohl None"
        end

        if event == "exit" then
            callback { items = items, isIncomplete = false }
        end
    end

    vim.fn.jobstart(
        string.format(
            "rg --no-filename --no-heading --no-line-number --word-regexp --color never --only-matching %s %s%s .",
            additional_arguments,
            q,
            pattern
        ),
        {
            on_stderr = on_event,
            on_stdout = on_event,
            on_exit = on_event,
            cwd = request.option.cwd or vim.fn.getcwd(),
        }
    )
end

return source
