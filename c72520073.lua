--闇の芸術家
local s,id=GetID()
function s.initial_effect(c)
	--defdown
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.defcon)
	e1:SetValue(s.defval)
	c:RegisterEffect(e1)
end
function s.defcon(e)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and c==Duel.GetAttackTarget() and bc:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.defval(e,c)
	return math.ceil(e:GetHandler():GetDefense()/2)
end
