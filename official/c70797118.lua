--雷電娘々
--Thunder Nyan Nyan
local s,id=GetID()
function s.initial_effect(c)
	--Destroy itself if you control a non-LIGHT monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(s.sdcon)
	c:RegisterEffect(e1)
end
function s.sdfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_ALL-ATTRIBUTE_LIGHT)
end
function s.sdcon(e)
	return Duel.IsExistingMatchingCard(s.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end