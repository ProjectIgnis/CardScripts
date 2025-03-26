--シャドウ・グール
--Shadow Ghoul
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
function s.value(e,c)
	return Duel.GetMatchingGroupCount(Card.IsMonster,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end