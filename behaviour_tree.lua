local BTCommon = require "bt_common"

local M = {}

local mt = {}
mt.__index = mt

M.priority  = require("priority")
M.sequence  = require("sequence")
M.parallel  = require("parallel")
M.invert    = require("invert")
M.mem_sequence  = require("mem_sequence")
M.mem_priority  = require("mem_priority")
M.weight_sequence = require("weight_sequence")
M.weight_priority = require("weight_priority")
M.always_succeed= require("always_succeed")
M.always_fail   = require("always_fail")

function mt:tick()
    BTCommon.execute(self.root, self)
    -- close open nodes if necessary
    local openNodes = self.open_nodes
    local lastOpen = self.last_open
    for node in pairs(lastOpen) do
        if not openNodes[node] and self[node].is_open then
            self[node].is_open = false
            if node.close then
                node:close(self)
            end
        end
        lastOpen[node] = nil
    end
    self.last_open = openNodes
    self.open_nodes = lastOpen  -- empty table
    self.frame = self.frame + 1
end

-- tick 实例：保存树的状态和黑板, [node] -> {is_open:boolean, ...}
-- @param robot     The robot to control
-- @param root      The behaviour tree root
-- @param log       [optional] the log function used to debug
function M.new(robot, root, log)
    local obj = {
        robot = robot,
        root = root,
        open_nodes = {},    -- 上一次 tick 运行中的节点
        last_open = {},
        frame = 0,          -- 帧数
        log = log
    }
    setmetatable(obj, mt)
    return obj
end

return M
