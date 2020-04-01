--Spell Proof Armor
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opt check
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	return aux.CanActivateSkill(tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	local c=e:GetHandler()
		--immune
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
		e1:SetValue(s.efilter)
		Duel.RegisterEffect(e1,tp)
		--decrease tribute
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DECREASE_TRIBUTE)
		e2:SetTargetRange(LOCATION_HAND,0)
		e2:SetTarget(s.atktg)
		e2:SetValue(0x10001)
		e2:SetLabelObject(e1)
		Duel.RegisterEffect(e2,tp)
		--flip back if non machine in GY
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_ADJUST)
		e3:SetCondition(s.con2)
		e3:SetOperation(s.op2)
		e3:SetLabelObject(e2)
		Duel.RegisterEffect(e3,tp)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(ep,id)~=0
end
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_SPELL)
end
function s.atktg(e,c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_MACHINE)
end
function s.cfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_MACHINE)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	local e1=e:GetLabelObject():GetLabelObject()
	local e2=e:GetLabelObject()
	e1:Reset()
	e2:Reset()
	e:Reset()
end
