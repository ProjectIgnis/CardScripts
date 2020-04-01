--TGX300
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
end
s.listed_series={0x27}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x27)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
