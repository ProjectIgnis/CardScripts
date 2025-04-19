--逆境適応
--Adapt to Adversity
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	 --Prevent destruction by opponent's effect for your Normal/Special Summoned WATER monsters
    	local e2=Effect.CreateEffect(c)
    	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    	e2:SetRange(LOCATION_SZONE)
    	e2:SetTargetRange(LOCATION_MZONE,0)
    	e2:SetTarget(s.indtg)
    	e2:SetValue(s.indesval)
    	c:RegisterEffect(e2)
end
function s.indtg(e,c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER) and (c:IsNormalSummoned() or c:IsSpecialSummoned())
end
function s.indesval(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end