--ガガガミラージュ
--Gagagamirage
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--"Gagaga" monsters you control can be treated as 2 materials for an Xyz Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GAGAGA))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Once per turn, you can Ignore the Attribute and Type requirements for and Xyz Summon
	local e2=e1:Clone()
	e2:SetCode(id)
	e2:SetCondition(function(e) return not e:GetHandler():HasFlagEffect(5160443) end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GAGAGA}