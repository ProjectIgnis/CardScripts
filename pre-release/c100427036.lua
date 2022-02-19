-- 黄金の雫の神碑
-- Mysterune of the Raging Storm
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateMysteruneQPEffect(c,id,0,nil,nil,function(_,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD) end)
	c:RegisterEffect(e1)
end
s.listed_series={0x27b}