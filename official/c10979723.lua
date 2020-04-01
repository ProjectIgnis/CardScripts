--アマゾネスペット虎
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--at limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
end
s.listed_series={0x4}
function s.val(e,c)
	return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsSetCard,0x4),c:GetControler(),LOCATION_MZONE,0,nil)*400
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x4) and c~=e:GetHandler()
end
