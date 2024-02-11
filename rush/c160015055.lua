--荒波
--Raging Waves
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Restrain attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.condition)
	e2:SetValue(aux.TRUE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.condition2)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return not c:IsRace(RACE_FISH|RACE_SEASERPENT|RACE_THUNDER|RACE_AQUA)
end
function s.condition(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCountRush(Card.IsMonster,tp,LOCATION_MZONE,0,nil)==1
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.condition2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCountRush(Card.IsMonster,tp,0,LOCATION_MZONE,nil)==1
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil)
end