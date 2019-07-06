--ロストガーディアン
local s,id=GetID()
function s.initial_effect(c)
	--base defense
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_DEFENSE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.defval)
	c:RegisterEffect(e1)
end
function s.defval(e,c)
	return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(RACE_ROCK),c:GetControler(),LOCATION_REMOVED,0,nil)*700
end
