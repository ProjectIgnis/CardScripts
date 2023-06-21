--ケミカライズ・ストラクチャーフォース
--Chemicalize Structure Force
local s,id=GetID()
function s.initial_effect(c)
	--Equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit,nil,nil,nil,nil)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--Cannot be destroyed by the card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(s.condition2)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO|RACE_AQUA|RACE_THUNDER) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.value(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=g:GetClassCount(Card.GetRace)
	return ct*300
end
function s.condition2(e)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsType(TYPE_MAXIMUM)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end