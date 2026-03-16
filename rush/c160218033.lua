--絶望の根源
--Root of Despair
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup,stage2=s.stage2})
	c:RegisterEffect(e1)
end
s.listed_names={160218025}
function s.ritualfil(c)
	return c:IsCode(160218025)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsRace(RACE_FIEND)
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	if Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
	end
end