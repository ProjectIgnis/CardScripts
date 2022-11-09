--Cyber Energy Amplified
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={303660}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,0,id)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Equip empowerment
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_EQUIP)
	e1:SetRange(0x5f)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(s.eqcon)
	e1:SetOperation(s.eqop)
	Duel.RegisterEffect(e1,tp)
end
function s.eqfilter(c,tp)
	return c:IsCode(303660) and c:IsControler(tp)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqfilter,1,nil,tp)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local ec=eg:GetFirst()
	local tc=ec:GetEquipTarget()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		tc:RegisterEffect(e1,true)
		if tc:GetFlagEffect(id)<1 then
			Duel.Hint(HINT_CARD,0,id)
			local e2=e1:Clone()
			e2:SetValue(tc:GetEquipGroup():FilterCount(Card.IsType,nil,TYPE_SPELL+TYPE_EQUIP)*300)
			tc:RegisterEffect(e2,true)
			tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end