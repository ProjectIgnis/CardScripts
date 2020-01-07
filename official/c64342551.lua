--水陸両用バグロス MK－3
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dircon)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI}
function s.dircon(e)
	return Duel.IsEnvironment(CARD_UMI)
end
