--[[

Disclamer : This code might used goodsignal modules. If u have any problem @ me on cubzh.                                    
,                             
\\ /`  _-_  \\/\\  /'\\ \\/\\ 
 \\   || \\ || || || || || || 
 /\\  ||/   || || || || || || 
/  \; \\,/  \\ \\ \\,/  \\ \\ 
                              
                              
End-User License Agreement


The Agreement:
- By downloading, installing, using, or copying the Modules, 
- you accept and agree to be bound by the terms of this EULA. 
- If you do not agree to all of the terms of this EULA, you may not download, install, use or copy the Modules.

    This End-User License Agreement (EULA) is a legal agreement between you (either as an individual or on behalf of an entity) 
    IF YOU DO NOT AGREE TO ALL OF THE TERMS OF THIS EULA, DO NOT INSTALL, USE OR COPY THE MODULES.

 Authors:                                                                   --
   stravant - July 31st, 2021 - created goodsignal.
   kamiko - October 23th, 2024 - Cubzh Code Snippet, created this files

]]
--!nocheck
-- Setup
eula = true

-- Modules Setup

local freeRunnerThread = nil

local function acquireRunnerThreadAndCallEventHandler(fn, ...)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	fn(...)
	-- The handler finished running, this runner thread is free again.
	freeRunnerThread = acquiredRunnerThread
end

local xenon = { __class = {"xenon"}}
xenon.__index = xenon


-- New Lighting Object
xenon.new = function(signal,fn)
    return setmetatable({
		_connected = true,
		__class = xenon,
		_fn = fn,
		_next = false,
	}, xenon)
end


function xenon:Disconnect()
	self._connected = false

	-- Unhook the node, but DON'T clear it. That way any fire calls that are
	-- currently sitting on this node will be able to iterate forwards off of
	-- it, but any subsequent fire calls will not hit it, and it will be GCed
	-- when no more fire calls are sitting on it.
	if self._class._handlerListHead == self then
		self._class._handlerListHead = self._next
	else
		local prev = self._class._handlerListHead
		while prev and prev._next ~= self do
			prev = prev._next
		end
		if prev then
			prev._next = self._next
		end
	end
    if collectgarbage("count") >= 10 then 
        collectgarbage("collect")
    else 
        return
    end
end

-- Make Xenon strict

setmetatable(xenon, {
	__index = function(_, key)
		error(("Attempt to get Xenon::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(_, key)
		error(("Attempt to set Xenon::%s (not a valid member)"):format(tostring(key)), 2)
	end,
})
-- check type while giving any
local export = {
    __type = {
        Xenon = {
            Disconnect: (self: Connection) -> (),
        }
         ,
        Lighting<T...> = {
            Connect: (self: Lighting<T...>, callback: (T...) -> ()) -> Xenon,
            Once: (self: Lighting<T...>, callback: (T...) -> ()) -> Xenon,
            Fire: (self: Lighting<T...>, T...) -> (),
        },
        Light<L...> = {
            Radial: (self : Light<L...>,callback: (L...) -> ()) -> Lighting<L...>
            VolumenticRadius: (self :Light<L...>, callback: (L...) -> ()) -> Lighting<L...> 
        }
        
    }
}

-- Lighting class
local Lighting = {}
Lighting.__index = Lighting

function Lighting.new<T...>(): Lighting<T...>
	return setmetatable({
		_handlerListHead = false,
	}, Lighting) :: any
end


function Lighting:Once(tb)
    local
    if type(tb) == "table" then
        table.sort(tb)
    end
    
	local cn
	cn = self:Connect(function(...)
		if cn._connected then
			cn:Disconnect()
		end
		fn(...)
	end)
	return cn
end

return Lighting
