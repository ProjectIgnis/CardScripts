--呪い移し
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp~=tp and Duel.IsChainDisablable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		local c=e:GetHandler()
		if not re then return end
		local tpe=c:GetType()
		if tpe&TYPE_FIELD~=0 then
			local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
			if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
				if fc then Duel.Destroy(fc,REASON_RULE) end
				fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
				if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			else
				fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
				if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			end
		end	
		Duel.ClearTargetCard()
		local tg=re:GetTarget()
		e:SetCategory(re:GetCategory())
		e:SetProperty(re:GetProperty())
		if re:GetCode()==EVENT_CHAINING then
			local chain=Duel.GetCurrentChain()-1
			local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
			local tc=te2:GetHandler()
			local g=Group.FromCards(tc)
			local p=tc:GetControler()
			if tg and tg(e,tp,g,p,chain,te2,REASON_EFFECT,p,0) then
				tg(e,tp,g,p,chain,te2,REASON_EFFECT,p,1)
			else
				return
			end
		elseif re:GetCode()==EVENT_FREE_CHAIN then
			if tg and tg(e,tp,eg,ep,ev,re,r,rp,0) then
				tg(e,tp,eg,ep,ev,re,r,rp,1)
			else
				return
			end
		else
			local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(re:GetCode(),true)
			if tg and tg(e,tp,teg,tep,tev,tre,tr,trp,0) then
				tg(e,tp,teg,tep,tev,tre,tr,trp,1)
			else
				return
			end
		end
		if tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD==0 then
			c:CancelToGrave(false)
		else
			c:CancelToGrave(true)
			local code=re:GetHandler():GetOriginalCode()
			c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,1)
		end
		local op=re:GetOperation()
		if re:GetCode()==EVENT_CHAINING then
			local chain=Duel.GetCurrentChain()-1
			local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
			local tc=te2:GetHandler()
			local g=Group.FromCards(tc)
			local p=tc:GetControler()
			if op then op(e,tp,g,p,chain,te2,REASON_EFFECT,p) end
		elseif re:GetCode()==EVENT_FREE_CHAIN then
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
		else
			local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(re:GetCode(),true)
			if op then op(e,tp,teg,tep,tev,tre,tr,trp) end
		end
	end
end
