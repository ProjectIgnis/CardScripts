--突撃ライノス
local s,id=GetID()
function s.initial_effect(c)
	--move
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(aux.seqmovcon)
	e1:SetOperation(aux.seqmovop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.atkcon)
	e2:SetValue(500)
	c:RegisterEffect(e2)
end
function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	local c=e:GetHandler()
	local at=Duel.GetAttackTarget()
	if (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and Duel.GetAttacker()==c and at then
		return c:GetColumnGroup():IsContains(at)
	else return false end
end
