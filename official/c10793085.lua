--鉄獣の咆哮
--Tri-Brigade Roar
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 "Tri-Brigade" card to the GY and apply a matching effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_TRI_BRIGADE}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_LINK),tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
function s.cfilter1(c)
	return s.cfilter(c) and c:GetAttack()>0
end
function s.cfilter2(c)
	return s.cfilter(c) and c:IsNegatableMonster()
end
function s.cfilter3(c)
	return s.cfilter(c) and c:IsAbleToHand()
end
function s.costfilter(c,op1,op2,op3)
	return c:IsSetCard(SET_TRI_BRIGADE) and c:IsAbleToGraveAsCost() and
		((c:IsMonster() and op1) or (c:IsSpell() and op2) or (c:IsTrap() and op3))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local phase=Duel.GetCurrentPhase()
	local op1=Duel.IsExistingTarget(s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and aux.StatChangeDamageStepCondition()
	local op2=Duel.IsExistingTarget(s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and phase~=PHASE_DAMAGE
	local op3=Duel.IsExistingTarget(s.cfilter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and phase~=PHASE_DAMAGE
	if chk==0 then return (op1 or op2 or op3) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,op1,op2,op3) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,op1,op2,op3):GetFirst()
	Duel.SendtoGrave(sc,REASON_COST)
	if sc:IsMonster() then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_ATKCHANGE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local tc=Duel.SelectTarget(tp,s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,-tc:GetAttack())
	elseif sc:IsSpell() then
		e:SetLabel(2)
		e:SetCategory(CATEGORY_DISABLE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectTarget(tp,s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	elseif sc:IsTrap() then
		e:SetLabel(3)
		e:SetCategory(CATEGORY_TOHAND)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectTarget(tp,s.cfilter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if e:GetLabel()==1 and tc:IsFaceup() then
		--Change its ATK to 0 until the end of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	elseif e:GetLabel()==2 and tc:IsFaceup() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		--Negate its effects until the end of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	elseif e:GetLabel()==3 then
		--Return it to the hand
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end