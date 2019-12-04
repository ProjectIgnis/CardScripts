--機械天使の絶対儀式
--Machine Angel Absolute Ritual
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcEqual(c,s.ritualfil,nil,nil,s.extrafil,s.extraop)
end
s.listed_series={0x2093}
function s.ritualfil(c)
	return c:IsSetCard(0x2093) and c:IsRitualMonster()
end
function s.mfilter(c)
	return c:HasLevel() and c:IsRace(RACE_WARRIOR+RACE_FAIRY) and c:IsAbleToDeck()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):Filter(Card.IsRace,nil,RACE_WARRIOR+RACE_FAIRY)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoDeck(mat2,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
