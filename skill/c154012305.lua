--Dice Return
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.roll_dice=true
function s.filter(c)
	return c.roll_dice and c:IsAbleToDeck()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetFlagEffect(ep,id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd Register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Dice Return
	local td=Duel.TossDice(tp,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,td,nil)
	if #g>0 then
		Duel.SendtoDeck(g,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
