--Mask Exchange
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={48948935,22610082}
function s.thfilter(c)
	return c:IsCode(48948935) and c:IsAbleToHand()
end
function s.tdfilter(c)
	return c:IsCode(22610082) and c:IsAbleToDeck()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	if Duel.GetFlagEffect(ep,id)>1 then return end 
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,1,nil) and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--tpd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Mask Exchange
	local hc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if Duel.SendtoHand(hc,tp,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,hc)
		local dc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,1,nil)
		if dc then
			Duel.SendtoDeck(dc,tp,2,REASON_EFFECT)
		end
	end
end
