--総剣司令 ガトムズ
--Commander Gottoms, Swordmaster
local s,id=GetID()
function s.initial_effect(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SABER))
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SABER}