--A・O・J サンダー・アーマー
--Ally of Justice Thunder Armor
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--"Ally fo Justice" monsters inflict piercing damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ALLY_OF_JUSTICE))
	c:RegisterEffect(e2)
end
s.listed_series={SET_ALLY_OF_JUSTICE}