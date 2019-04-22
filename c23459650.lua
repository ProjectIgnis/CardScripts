--ネフティスの輪廻
--Rebirth of Nephthys
local s,id=GetID()
function s.initial_effect(c)
	aux.AddRitualProcGreater(c,s.ritualfil,nil,nil,nil,nil,s.stage2)
end
s.fit_monster={88176533,24175232}
function s.ritualfil(c)
	return c:IsSetCard(0x11f) and c:IsRitualMonster()
end
function s.mfilter(c)
	if c:IsPreviousLocation(LOCATION_MZONE) then
		local code=c:GetPreviousCodeOnField()
		return code == 88176533 or code == 24175232
	else
		return c:IsCode(88176533,24175232)
	end
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if mg:IsExists(s.mfilter,1,nil) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,1,e:GetHandler())
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
