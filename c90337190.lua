--魚雷魚
local s,id=GetID()
function s.initial_effect(c)
	--immune spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.econ)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI}
function s.econ(e)
	return Duel.IsEnvironment(CARD_UMI)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
