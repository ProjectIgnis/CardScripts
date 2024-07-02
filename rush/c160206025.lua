--融合
--Polymerization (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	Fusion.RegisterSummonEff(c,nil,s.matfilter)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_HAND|LOCATION_MZONE) and c:IsAbleToGrave()
end