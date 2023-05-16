--幻壊大鎧戸
--Demolition Shutter
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.condition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Cannot be destroyed by the card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(s.condition2)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--immune to des
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.condition2)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WYRM) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.condition(e)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsAttackPos()
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(nil,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end