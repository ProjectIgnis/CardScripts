--Skyforce Kishin
--Berserker of the Tenyi
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_LINK,lc,sumtype,tp)
end