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
    local quote = "'"
    if vim.o.shell == "cmd.exe" then
        quote = '"'
    end
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
                    "rg --no-filename --no-heading --no-line-number --word-regexp --color never --only-matching %s %s%s%s%s .",
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
