--Spell Dispel
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={20765952}
function s.filter(c,tp)
	return c:IsCode(20765952) and c:GetCardTargetCount()>0 and c:GetFirstCardTarget():IsType(TYPE_SPELL) and c:IsControler(tp)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--counter
	if Duel.GetFlagEffect(ep,id)>1 then return end 
	--condition
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,0,1,nil,tp) and aux.CanActivateSkill(tp) 
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--tpd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Dispel
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,0,nil,tp)
	for tc in aux.Next(g) do
		local sc=tc:GetFirstCardTarget()
		if sc then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_SZONE+LOCATION_FZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			sc:RegisterEffect(e1,true)
		end
	end
end