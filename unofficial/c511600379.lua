--ジョーズマン (Anime)
--Jawsman (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkup)
	c:RegisterEffect(e1)
end
function s.atkup(e,c)
	return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_WATER),c:GetControler(),LOCATION_MZONE,0,c)*300
end
