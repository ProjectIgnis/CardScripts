--Metal Baboon, Ruffian of the Forest
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2,2)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsLevelAbove(5) and c:IsRace(RACE_BEAST,lc,sumtype,tp)
end
