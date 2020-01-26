--Hidden Parasite
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)	
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--twice per duel check
	if Duel.GetFlagEffect(ep,id)<2 then return end
	--opt check
	if Duel.GetFlagEffect(ep,id+100)<1 then return end
	--condition
	return aux.CanActivateSkill(tp)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,0,id|(1<<32))
	Duel.Hint(HINT_CARD,0,id)
	--used skill flag register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--opt register
	Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,0)
	local c=e:GetHandler()
	
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(RACE_INSECT)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	--half damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCondition(s.dcon)
	e1:SetOperation(s.dop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	Duel.HalfBattleDamage(ep)
end
