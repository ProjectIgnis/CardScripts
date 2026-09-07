--Endless Traps
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--OPD check
	if Duel.HasFlagEffect(tp,id) then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetMatchingGroupCount(Card.IsTrap,tp,LOCATION_GRAVE,0,nil)==3
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Trap movement
	local g=Duel.GetMatchingGroup(Card.IsTrap,tp,LOCATION_GRAVE,0,nil)
	local tc1=g:RandomSelect(tp,1):GetFirst()
	--Add 1 random Trap from your GY to your hand
	if tc1:IsAbleToHand() then
		g:RemoveCard(tc1)
		Duel.SendtoHand(tc1,tp,REASON_EFFECT)
	end
	--Shuffle 1 random trap from your GY into your Deck
	local tc2=g:RandomSelect(tp,1):GetFirst()
	if tc2:IsAbleToDeck() then
		g:RemoveCard(tc2)
		Duel.SendtoDeck(tc2,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	Duel.BreakEffect()
	--Banish 1 random Trap from your GY
	if g:GetFirst():IsAbleToRemove() then
		Duel.Remove(g:GetFirst(),POS_FACEUP,REASON_EFFECT)
	end
end
	
