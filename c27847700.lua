--融合
--Polymerization
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterEffect(Fusion.AddSummonEff(c))
end