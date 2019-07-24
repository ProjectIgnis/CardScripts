--Rank Revolution
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,0,s.filter,CATEGORY_DISABLE,nil,nil,0x1c0,s.condition)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.bttg)
	e2:SetValue(s.distg)
	c:RegisterEffect(e2)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local tc=g:GetFirst()
	return #g==1 and tc:IsFaceup() and tc:IsType(TYPE_XYZ)
end
function s.discon(e)
	return e:GetHandler():GetFirstCardTarget()
end
function s.distg(e,c)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and ((c:GetRank()>0 and c:GetRank()>tc:GetRank()) or (c:GetLevel()>0 and c:GetLevel()>tc:GetRank()))
end
function s.bttg(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
