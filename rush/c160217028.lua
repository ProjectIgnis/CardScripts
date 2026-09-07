--畑が荒らされて困ってます！
--I'm Having Trouble with My Fields Being Destroyed!
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup,stage2=s.stage2})
	c:RegisterEffect(e1)
end
s.listed_names={160217018,160217020}
function s.ritualfil(c)
	return c:IsCode(160217018,160217020)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup()
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(6) and c:IsRace(RACE_BEAST|RACE_WINGEDBEAST)
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,1,nil)
		if #sg==0 then return end
		local sg2=sg:AddMaximumCheck()
		Duel.HintSelection(sg2)
		Duel.BreakEffect()
		Duel.Destroy(sg,REASON_EFFECT)
	end
end