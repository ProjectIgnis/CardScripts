--KC-1 Crayton
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.upval)
	c:RegisterEffect(e2)
end
s.listed_names={511000882}
function s.upval(e,c)
	return Duel.GetMatchingGroupCount(s.upfilter,c:GetControler(),LOCATION_MZONE,0,nil)*500
end
function s.upfilter(c)
	return c:IsFaceup() and c:IsCode(511000882)
end
