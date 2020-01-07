--Rose Papillon
local s,id=GetID()
function s.initial_effect(c)
	--direct attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(s.dircon)
	c:RegisterEffect(e4)
end
function s.dircon(e)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_INSECT),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
