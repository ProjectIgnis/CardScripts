--登竜華幻巄門
--Ryu-Ge Realm - Wyrm Winds
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Ryu-Ge Realm - Wyrm Winds"
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Any monster sent from the field to the GY during your opponent's turn is banished instead
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(function(e) return Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) end)
	e1:SetTarget(function(e,c) return Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c) end)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--Change the ATK of 1 face-up monster to 0
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	--Grant the above effect to "Ryu-Ge" Pendulum Monsters and Level 10 or higher monsters whose original Type is Wyrm you control
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.efftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--Monsters affected by this card's effect become effect monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.efftg)
	e4:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e4)
end
s.listed_series={SET_RYU_GE}
s.listed_names={id}
function s.efftg(e,c)
	return (c:IsSetCard(SET_RYU_GE) and c:IsType(TYPE_PENDULUM)) or (c:IsLevelAbove(10) and c:IsOriginalRace(RACE_WYRM))
end
function s.costfilter(c)
	return c:IsSetCard(SET_RYU_GE) and c:IsContinuousSpell() and c:IsFaceup() and c:IsAbleToDeckAsCost()
		and Duel.IsExistingTarget(Card.HasNonZeroAttack,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:HasNonZeroAttack() end
	if chk==0 then return Duel.IsExistingTarget(Card.HasNonZeroAttack,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectTarget(tp,Card.HasNonZeroAttack,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,-tc:GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Change its ATK to 0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end