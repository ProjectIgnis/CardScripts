--The World's Greatest Fisherman
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)	
end

function s.cfilter(c)
	local lv=c:GetOriginalLevel()
	return c:GetLevel()>0 and c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
	and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,0,1,nil,lv) 
end
function s.filter2(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv*2)  and c:IsAbleToHand() and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opt check
	if Duel.GetFlagEffect(ep,id)==0 then return end
	--condition
	return aux.CanActivateSkill(tp) 
	and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_HAND,0,1,nil)
	and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=2
	and Duel.CheckLPCost(tp,100)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,0,id|(1<<32))
	Duel.Hint(HINT_CARD,0,id)
	--opt register
	Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,0)
	
	Duel.PayLPCost(tp,500)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	local lvl=g:GetFirst():GetLevel()
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil,lvl)
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SKILL_FLIP,0,id|(2<<32))
	end
end