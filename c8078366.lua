--海皇の突撃兵
local s,id=GetID()
function s.initial_effect(c)
	--ayk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetValue(800)
	c:RegisterEffect(e1)
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_FISH+RACE_SEASERPENT+RACE_AQUA),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
