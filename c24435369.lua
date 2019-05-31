--マーメイド・ナイト
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(s.dircon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI}
function s.dircon(e)
	return Duel.IsEnvironment(CARD_UMI)
end
