--鉄の騎士 (Anime)
--Iron Knight (Anime)
--Jackpro 1.3
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.sdcon)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
end
s.listed_names={41916534}
function s.filter(c)
	return c:IsFaceup() and c:IsCode(41916534)
end
function s.sdcon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end