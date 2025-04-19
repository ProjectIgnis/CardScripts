--キャプテン・ウィング
local s,id=GetID()
function s.initial_effect(c)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.pcon)
	c:RegisterEffect(e1)
end
s.listed_names={450000110}
function s.pcon(e)
	return Duel.IsEnvironment(450000110)
end