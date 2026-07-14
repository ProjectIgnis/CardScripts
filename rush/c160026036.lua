--深竜の契約者
--Contractor of the Abyssal Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160204044,1,s.ffilter,1)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(s.target)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--Cannot Change Battle Position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.target)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
end
s.named_material={160204044}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,scard,sumtype,tp) and c:IsType(TYPE_EFFECT) and c:IsLevelBelow(8)
end
function s.target(e,c)
	return c:IsAttackPos() and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()==e:GetOwnerPlayer()
end