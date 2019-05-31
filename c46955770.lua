--墓守の異端者
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.con)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_NECROVALLEY}
function s.con(e)
	return Duel.IsEnvironment(CARD_NECROVALLEY)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
