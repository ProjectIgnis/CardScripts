--属性重力－アトリビュート・グラビティ
--Attribute Gravity
--Rescripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Must attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
end
function s.atktg(e,c)
	e:SetLabel(c:GetAttribute())
	return Duel.IsExistingMatchingCard(s.adval,c:GetControler(),0,LOCATION_MZONE,1,nil,c:GetAttribute())
end
function s.adval(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
function s.atkval(e,c)
	return c:IsAttribute(e:GetLabel())
end