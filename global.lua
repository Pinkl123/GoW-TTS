local seen={}

function dump(t,i)
    seen[t]=true
    local s={}
    local n=0
    for k in pairs(t) do
        n=n+1 s[n]=k
    end
    table.sort(s)
    for k,v in ipairs(s) do
        print(i,v)
        v=t[v]
        if type(v)=="table" and not seen[v] then
            dump(v,i.." ")
        end
    end
end

--[[ Lua code See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The osnLoad event is called after the game save finishes loading. --]]
function onLoad()
    -- print('onLoad!')
end

--[[ The onUpdate event is called once per frame. --]]
function onUpdate()
    --[[ print('onUpdate loop!') --]]
    -- print(getGlobalScriptVar("stats").MPC)
end

-- dump(_G, "")
