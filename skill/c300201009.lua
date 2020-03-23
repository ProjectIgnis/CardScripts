--Millenium Eye
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--ask if you want to activate the skill or not
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--look at hand
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
			Duel.ShuffleDeck(g:GetFirst():GetControler())
			Duel.BreakEffect()
			Duel.Draw(g:GetFirst():GetControler(),#g,REASON_EFFECT)
		end
	end
end
