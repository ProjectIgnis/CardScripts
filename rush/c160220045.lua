--ロストリーム－巡りの雲海
--Lostream - The Circulating Sea of Clouds
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	return a:IsControler(tp) and a:IsRace(RACE_SEASERPENT) and a:IsAttribute(ATTRIBUTE_WIND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttacker():GetBattleTarget()
	if bc and bc:IsLocation(LOCATION_GRAVE) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end