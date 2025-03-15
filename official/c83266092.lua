--超古代生物の墓場
--Grave of the Super Ancient Organism
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE|TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--Level 6 or higher Special Summoned monsters on the field cannot declare attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
	--Players cannot activate the effects of Level 6 or higher Special Summoned monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetValue(s.value)
	c:RegisterEffect(e3)
end
function s.target(e,c)
	return c:IsLevelAbove(6) and c:IsSpecialSummoned()
end
function s.value(e,re,tp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsOnField() and rc:IsLevelAbove(6) and rc:IsSpecialSummoned()
end