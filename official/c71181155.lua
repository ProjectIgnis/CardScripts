--幻獣クロスウィング
--Phantom Beast Cross-Wing
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_PHANTOM_BEAST))
	e1:SetValue(300)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PHANTOM_BEAST}