-- プライム・ピアース・ジャイアント
-- Praime Pierce Giant
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160016001,1,s.matfilter,1)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--cannot be used
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.cond)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.named_material={160016001}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT,scard,sumtype,tp) and c:IsLevelBelow(8)
end
function s.target(e,c)
	return c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.cond(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end