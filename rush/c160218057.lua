--スピード・メジャー
--Speed Major
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160218060,1,s.ffilter,1)
	--Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
end
s.named_material={160218060}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and c:IsType(TYPE_EFFECT) and c:IsDefenseBelow(2000)
end
function s.target(e,c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH|ATTRIBUTE_WIND) and c~=e:GetHandler()
end
function s.cfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH|ATTRIBUTE_WIND) and c:GetBaseAttack()>=2600
end
function s.value(e,c)
	if Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) then return 1000 end
	return 500
end