--デス・アクセル
--Des Accelerator 
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 Speed counter on your card(s) for every 300 Damage you take
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local d=math.floor(ev/300)
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if not tc or Duel.IsPlayerAffectedByEffect(tp,100100090) then return end
	tc:RegisterFlagEffect(110000000,RESET_CHAIN,0,1)
	if (12-tc:GetCounter(0x91))<d then
		tc:AddCounter(0x91,12-tc:GetCounter(0x91))
	else
		tc:AddCounter(0x91,d)
	end
end