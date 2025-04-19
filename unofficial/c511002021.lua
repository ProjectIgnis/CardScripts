--真紅眼の闇竜
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsSetCard(SET_JUNK) and c:IsMonster()
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*400
end