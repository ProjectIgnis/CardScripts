--ピュアラヴ・エンジェル
--Pure Love Angel
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--Take no battle damage involving this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(s.tglimit)
	c:RegisterEffect(e2)
end
function s.val(e,c)
	return c:IsAttackAbove(2500)
end
function s.tglimit(e,c)
	return c and c:IsLevelBelow(9)
end