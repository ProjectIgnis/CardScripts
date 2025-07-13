--チアフルウェイトレス
--Cheerful Waitress
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--Take no battle damage involving this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.target(e,c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelAbove(7) and c:GetBaseDefense()==1200
end