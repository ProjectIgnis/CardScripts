--E・HERO ザ・ヒート
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
s.listed_series={0x3008}
function s.val(e,c)
	return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsSetCard,0x3008),c:GetControler(),LOCATION_MZONE,0,nil)*200
end
