--デス・アクセル
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
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
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	if not tc or Duel.IsPlayerAffectedByEffect(tp,100100090) then return end
	tc:RegisterFlagEffect(110000000,RESET_CHAIN,0,1)
	if (12-tc:GetCounter(0x91))<d then
		tc:AddCounter(0x91,12-tc:GetCounter(0x91))
	else tc:AddCounter(0x91,d) end
end
