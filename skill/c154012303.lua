--Dice Booster
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)==0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--Shuffle  your Deck
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local td=Duel.TossDice(tp,1)
	local atk=td*50
	if (td==1 or td==6) then
		Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
	else
		Duel.RegisterFlagEffect(ep,id,0,0,0)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
