---@class rg.Message
---@field public type 'begin'|'match'|'context'|'end'
---@field public data rg.MessageData

---@class rg.MessageData
---@field public path       rg.MessageDataPath
---@field public lines      rg.MessageDataLines|nil
---@field public submatches rg.MessageSubmatch[]|nil

---@class rg.MessageDataPath
---@field public text string

---@class rg.MessageDataLines
---@field public text string

---@class rg.MessageSubmatch
---@field public match rg.MessageSubmatchMatch

---@class rg.MessageSubmatchMatch
---@field public text string|nil
