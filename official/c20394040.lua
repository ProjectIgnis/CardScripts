--バーバリアン1号
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
end
s.listed_names={40453765}
function s.value(e,c)
	return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsCode,40453765),c:GetControler(),LOCATION_MZONE,0,nil)*500
end
