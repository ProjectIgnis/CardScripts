--Dice Recovery
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)==0 
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--Shuffle  your Deck
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local td=Duel.TossDice(tp,1)
	local lp=td*200
	if (td==1 or td==6) then
		Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
	else
		Duel.RegisterFlagEffect(ep,id,0,0,0)
	end
	Duel.Recover(tp,lp,REASON_EFFECT)
end

