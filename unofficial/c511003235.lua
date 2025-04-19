--ビークロイド・コネクション・ゾーン (Anime)
--Vehicroid Connection Zone (Anime)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 "Vehicroid" Fusion monster 
	--Using monsters from hand or field as fusion material
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_VEHICROID),nil,nil,nil,nil,nil)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	c:RegisterEffect(e1)
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VEHICROID}