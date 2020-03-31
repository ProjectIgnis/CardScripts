--魔轟神ウルストス
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
s.listed_series={0x35}
function s.con(e)
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_HAND,0)<=2
end
function s.tg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x35)
end
