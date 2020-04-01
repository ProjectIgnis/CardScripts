--The World's Greatest Fisherman
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
function s.cfilter(c)
	local lvl=c:GetOriginalLevel()
	return c:GetLevel()>0 and c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
	and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,lvl,c:GetCode())
end
function s.thfilter(c,lvl,code)
	return c:IsFaceup() and c:IsLevelBelow(lvl*2)  and c:IsAbleToHand() and c:IsAttribute(ATTRIBUTE_WATER)
	and not c:IsCode(code)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opt check
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) 
	and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
	and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=2
	and Duel.CheckLPCost(tp,500)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.PayLPCost(tp,500)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	local lvl=g:GetFirst():GetLevel()
	local code=g:GetFirst():GetCode()
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,lvl,code)
	if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	end
end
