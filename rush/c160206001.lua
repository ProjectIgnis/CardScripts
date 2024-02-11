--Ｆ・Ｇ・Ｄ
--Five-Headed Dragon (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon procedure
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),5)
	--Must be Fusion Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle with monsters with matching attributes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.indesfilter)
	c:RegisterEffect(e2)
end
function s.indesfilter(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND)
end