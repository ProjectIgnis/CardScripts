--Card Shuffle (Skill)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.CheckLPCost(tp,300)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--Shuffle  your Deck
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.PayLPCost(tp,300)
	Duel.ShuffleDeck(tp)
end
