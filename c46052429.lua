--高等儀式術
local s,id=GetID()
function s.initial_effect(c)
	aux.AddRitualProcEqual(c,aux.FilterBoolFunction(Card.IsRitualMonster),nil,nil,s.extrafil,s.extraop,s.matfil)
end
function s.matfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(mg,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.matfil(c)
	return c:IsLocation(LOCATION_DECK)
end