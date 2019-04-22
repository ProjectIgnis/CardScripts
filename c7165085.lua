--おとり人形
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFaceup() then
		if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			c:CancelToGrave()
			Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		end
		return
	end
	if tc:IsType(TYPE_TRAP) then
		local te=tc:GetActivateEffect()
		local tep=tc:GetControler()
		local condition
		local cost
		local target
		local operation
		if te then
			condition=te:GetCondition()
			cost=te:GetCost()
			target=te:GetTarget()
			operation=te:GetOperation()
		end
		local chk=te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep)
			and (not condition or condition(te,tep,eg,ep,ev,re,r,rp))
			and (not cost or cost(te,tep,eg,ep,ev,re,r,rp,0))
			and (not target or target(te,tep,eg,ep,ev,re,r,rp,0))
		Duel.ChangePosition(tc,POS_FACEUP)
		Duel.ConfirmCards(tp,tc)
		if chk then
			Duel.ClearTargetCard()
			e:SetProperty(te:GetProperty())
			Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
			if tc:GetType()==TYPE_TRAP then
				tc:CancelToGrave(false)
			end
			tc:CreateEffectRelation(te)
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			if target~=te:GetTarget() then
				target=te:GetTarget()
			end
			if target then target(te,tep,eg,ep,ev,re,r,rp,1) end
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			for tg in aux.Next(g) do
				tg:CreateEffectRelation(te)
			end
			tc:SetStatus(STATUS_ACTIVATED,true)
			if tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
				tc:SetStatus(STATUS_LEAVE_CONFIRMED,false)
			end
			if operation~=te:GetOperation() then
				operation=te:GetOperation()
			end
			if operation then operation(te,tep,eg,ep,ev,re,r,rp) end
			tc:ReleaseEffectRelation(te)
			for tg in aux.Next(g) do
				tg:ReleaseEffectRelation(te)
			end
		else
			if Duel.Destroy(tc,REASON_EFFECT)~=0 then
				Duel.SendtoGrave(tc,REASON_RULE)
			end
		end
	else
		Duel.ConfirmCards(tp,tc)
	end
	if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		c:CancelToGrave()
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
	end
end