--Millennium Necklace
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--OPD check
	if Duel.GetFlagEffect(tp,id)>0 then return end
	--condition
	return Duel.GetCurrentChain()==0 and Duel.IsTurnPlayer(1-tp) and Duel.GetTurnCount()>1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--Ask if you want to activate the skill or not
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Sort the top 3 cards of your opponnet's Deck
	Duel.SortDecktop(tp,1-tp,3)
end
