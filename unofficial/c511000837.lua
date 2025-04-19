--悪鬼蹂躙
--Wicked Trample
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Double any battle damage your opponent takes, except from direct attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function() return Duel.GetAttackTarget()~=nil end)
	e2:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e2)
end