--武装再生
--Arms Regeneration
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	-- Make a monster gain 800 ATK or Set or Equip a card from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.eqcfilter(c,tp)
	return c:IsEquipSpell() and (c:IsSSetable()
		or Duel.IsExistingMatchingCard(s.eqtfilter,tp,LOCATION_MZONE,0,1,nil,c,tp))
end
function s.eqtfilter(c,ec,tp)
	return c:IsFaceup() and ec:CheckEquipTarget(c) and ec:CheckUniqueOnField(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local phase=Duel.GetCurrentPhase()
	local b1=Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and (phase~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	local b2=ft>0 and Duel.IsExistingTarget(s.eqcfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) and phase~=PHASE_DAMAGE
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,800)
	else
		e:SetCategory(CATEGORY_EQUIP)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local tc=Duel.SelectTarget(tp,s.eqcfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp):GetFirst()
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,tc:GetControler(),0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,tc,1,tp,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			tc:UpdateAttack(800,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,e:GetHandler())
		end
	else
		if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
		local eqpc=Duel.GetFirstTarget()
		if not eqpc:IsRelateToEffect(e) then return end
		local b1=eqpc:IsSSetable()
		local b2=Duel.IsExistingMatchingCard(s.eqtfilter,tp,LOCATION_MZONE,0,1,nil,eqpc,tp)
		if not (b1 or b2) then return end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,4)},
			{b2,aux.Stringid(id,5)})
		if op==1 then
			Duel.SSet(tp,eqpc)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local eqptg=Duel.SelectMatchingCard(tp,s.eqtfilter,tp,LOCATION_MZONE,0,1,1,nil,eqpc,tp):GetFirst()
			if not eqptg then return end
			Duel.HintSelection(eqptg,true)
			Duel.Equip(tp,eqpc,eqptg)
		end
	end
end