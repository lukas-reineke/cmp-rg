local uv = vim.uv or vim.loop
local debug = require "cmp.utils.debug"

---@alias rg.Callback fun(data: string[], event: "stdout"|"stderr"|"exit"): nil

---@class rg.Pipe
---@field pipe uv_pipe_t
---@field private event string
---@field private callback rg.Callback
---@field private is_closed boolean
---@field private tmp_out string
local Pipe = {}

---@param event string
---@param callback rg.Callback
---@return rg.Pipe
Pipe.new = function(event, callback)
    return setmetatable({ event = event, callback = callback, pipe = uv.new_pipe(), tmp_out = "" }, { __index = Pipe })
end

function Pipe:close()
    if not self.is_closed then
        self.pipe:close()
        self.is_closed = true
    end
end

function Pipe:read_start()
    self.pipe:read_start(function(err, chunk)
        assert(not err, err)
        if not chunk then
            return
        end
        self.tmp_out = self.tmp_out .. chunk:gsub("\r\n", "\n")
        local lines = vim.split(self.tmp_out, "\n", { plain = true })
        if #lines > 1 then
            self.tmp_out = lines[#lines]
            local data = {}
            for i = 1, #lines - 1 do
                data[i] = lines[i]
            end
            self.callback(data, self.event)
        end
    end)
end

---@class rg.Process
---@field callback rg.Callback
---@field private handle uv_process_t?
---@field private cmd string
---@field private args string[]
---@field private stdout rg.Pipe
---@field private stderr rg.Pipe
---@field private cwd string
local Process = {}

---@param cmd string
---@param args string[]
---@param callback rg.Callback
---@param options { cwd: string }?
---@return rg.Process
Process.new = function(cmd, args, callback, options)
    options = vim.tbl_extend("force", { cwd = uv.cwd() }, options or {})
    return setmetatable({
        cmd = cmd,
        args = args,
        callback = callback,
        stdout = Pipe.new("stdout", callback),
        stderr = Pipe.new("stderr", callback),
        cwd = options.cwd,
    }, { __index = Process })
end

---@return rg.Process
function Process:run()
    local err
    self.handle, err = uv.spawn(self.cmd, {
        args = self.args,
        cwd = self.cwd,
        stdio = { nil, self.stdout.pipe, self.stderr.pipe },
    }, function(_, _)
        self:pipe_close()
        if self.handle and not self.handle:is_closing() then
            self.handle:close()
        end
        self.callback({}, "exit")
    end)
    if not self.handle then
        self:pipe_close()
        debug.log("rg", "process cannot spawn", { cmd = self.cmd, args = self.args, err = err })
    else
        self.stdout:read_start()
        self.stderr:read_start()
    end
    return self
end

function Process:kill()
    if self.handle then
        self:pipe_close()
        if not self.handle:is_closing() then
            self.handle:close()
        end
    end
end

function Process:pipe_close()
    self.stdout:close()
    self.stderr:close()
end

return Process
