--幻奏の音女エレジー
--Elegy the Melodious Diva
local s,id=GetID()
function s.initial_effect(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	e2:SetValue(300)
	e2:SetCondition(s.tgcon)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MELODIOUS}
function s.indtg(e,c)
	return c:IsSetCard(SET_MELODIOUS) and c:IsSpecialSummoned()
end
function s.tgcon(e)
	return e:GetHandler():IsSpecialSummoned()
end