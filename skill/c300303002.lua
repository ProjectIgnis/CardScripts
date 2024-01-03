--It's No Monster, It's a God!
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
function s.filter(c)
	return c:IsCode(10000000) and c:IsAbleToHand()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(ep,id)==0
		and aux.CanActivateSkill(tp)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) 
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) 
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--Flip this card over when it is activated
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Once per duel limit
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Effect
	local mxct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,mxct,REASON_EFFECT|REASON_DISCARD)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end