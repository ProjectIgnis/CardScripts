--魔法移し
--Bounce Spell
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	local bool_a=c:IsType(TYPE_PENDULUM) and Duel.GetLocationCount(tp,LOCATION_PZONE)>0
	local bool_b=c:IsType(TYPE_FIELD)
	local bool_c=not c:IsType(TYPE_PENDULUM) and not c:IsType(TYPE_FIELD) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	return c:IsFaceup() and c:IsSpell() and not c:IsOriginalCode(id)
		and (bool_a or bool_b or bool_c) and c:IsAbleToChangeControler()
		and c:CheckActivateEffect(true,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.filter(chkc,tp) and not chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_SZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local toGrave=false
		if tc:IsStatus(STATUS_LEAVE_CONFIRMED) then
			toGrave=true
		end
		local loc=tc:GetLocation()
		if tc:IsType(TYPE_PENDULUM) then loc=LOCATION_PZONE end
		if tc:IsType(TYPE_FIELD) then loc=LOCATION_FZONE end
		if not Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true) then return end
		Duel.ClearTargetCard()
		for ttc in tc:GetCardTarget():Iter() do
			tc:CancelCardTarget(ttc)
		end
		tc:ResetEffect(RESET_TOFIELD,RESET_EVENT)
		if toGrave then
			tc:CancelToGrave(false)
		end
		Duel.Hint(HINT_CARD,0,tc:GetCode())
		local te=tc:GetActivateEffect()
		local tg=te:GetTarget()
		local op=te:GetOperation()
		tc:CreateEffectRelation(te)
		if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		for etc in aux.Next(g) do
			etc:CreateEffectRelation(te)
		end
		if op then op(te,tp,eg,ep,ev,re,r,rp) end
		tc:ReleaseEffectRelation(te)
		for etc in aux.Next(g) do
			etc:ReleaseEffectRelation(te)
		end
	end
end