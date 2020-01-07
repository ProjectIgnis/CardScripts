--黒翼の魔術師
local s,id=GetID()
function s.initial_effect(c)
	--Trap activate in set turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_ASSAULT_MODE))
	c:RegisterEffect(e1)
end
s.listed_names={CARD_ASSAULT_MODE}
