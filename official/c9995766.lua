--宮廷のしきたり
--Imperial Custom

local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Continuous traps cannot be destroyed by battle or card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(s.infilter)
	e2:SetValue(s.indesval)
	c:RegisterEffect(e2)
end
function s.infilter(e,c)
	return (c:GetType()&0x20004)==0x20004 and c:GetCode()~=id
end
function s.indesval(e,re,r,rp)
	return (r&REASON_RULE)==0
end
