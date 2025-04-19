--環状列石の結界
--Stonehenge Shield
--Rescripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,nil,s.filter,CATEGORY_DISABLE+CATEGORY_ATKCHANGE,nil,nil,0x1c0,nil,nil,s.target)	
	--Destroy this card if target monster leaves the field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--Negate target monster's effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e4)
	--Set target monster's ATK to 0
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_ATTACK)
	e5:SetValue(0)
	c:RegisterEffect(e5)
	--Target monster cannot attack
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e6)
end
function s.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>2999
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,0)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end