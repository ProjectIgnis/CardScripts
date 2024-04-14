--ダークマター・ナイト
--Dark Matter Knight
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Gains 500 ATK per each Fusion monster or face-down monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFacedown() or c:IsType(TYPE_FUSION)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)*500
end