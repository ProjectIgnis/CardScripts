--Skyforce Monk
local s,id=GetID()
function s.initial_effect(c)
	--Link summon method
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
end
function s.matfilter(c,lc,stype,tp)
	return c:IsSetCard(0x12c,lc,stype,tp) and not c:IsType(TYPE_LINK,lc,stype,tp)
end