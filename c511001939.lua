--コピーキャット
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(511001408)
	c:RegisterEffect(e2)
end
function s.cfilter(c,e,tp,eg,ep,ev,re,r,rp,chain)
	if not c:IsType(TYPE_MONSTER) and (c:IsHasEffect(511001283) or c:IsHasEffect(511001408)) then return false end
	return s.filter(c,e,tp,eg,ep,ev,re,r,rp)
end
function s.filter(c,e,tp,eg,ep,ev,re,r,rp,chain)
	local ref=c:GetReasonEffect()
	if not c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_RULE) 
		and (not ref or ref:GetHandler():GetOwner()==tp) then return false end
	if not c:IsPreviousLocation(LOCATION_ONFIELD) then return false end
	if c:IsType(TYPE_MONSTER) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	else
		local te=c:GetActivateEffect()
		if not te then return false end
		local cost=te:GetCost()
		local target=te:GetTarget()
		if te:GetCode()==EVENT_CHAINING then
			if chain<=0 then return false end
			local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
			local tc=te2:GetHandler()
			local g=Group.FromCards(tc)
			local p=tc:GetControler()
			return (not target or target(e,tp,g,p,chain,te2,REASON_EFFECT,p,0))
		elseif te:GetCode()==EVENT_FREE_CHAIN then
			if chk then copychain=1 end
			return (not target or target(e,tp,eg,ep,ev,re,r,rp,0))
		else
			local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
			return res and (not target or target(e,tp,teg,tep,tev,tre,tr,trp,0))
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local chain=Duel.GetCurrentChain()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.filter(chkc,e,tp,eg,ep,ev,re,r,rp,chain) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,eg,ep,ev,re,r,rp,chain) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	chain=chain-1
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,eg,ep,ev,re,r,rp,chain)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chain=Duel.GetCurrentChain()-1
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_MONSTER) then
		Duel.MoveToField(c,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
		c:SetStatus(STATUS_PROC_COMPLETE,true)
		c:SetStatus(STATUS_SPSUMMON_TURN,true)
		c:AddMonsterAttribute(tc:GetType())
		c:AddMonsterAttributeComplete()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(tc:GetDefense())
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_BASE_ATTACK)
		e3:SetValue(tc:GetAttack())
		c:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(tc:GetRace())
		c:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(tc:GetAttribute())
		c:RegisterEffect(e5)
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD,1)
		Duel.RaiseSingleEvent(c,EVENT_SPSUMMON_SUCCESS,e,REASON_EFFECT,rp,ep,0)
	else
		local te=tc:GetActivateEffect()
		if not te or not s.cfilter(tc,e,tp,eg,ep,ev,re,r,rp,chain) then return end
		local tpe=tc:GetType()
		if (tpe&TYPE_FIELD)~=0 then
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
		local tg=te:GetTarget()
		e:SetCategory(te:GetCategory())
		e:SetProperty(te:GetProperty())
		if te:GetCode()==EVENT_CHAINING then
			local chain=Duel.GetCurrentChain()-1
			local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
			local tc=te2:GetHandler()
			local g=Group.FromCards(tc)
			local p=tc:GetControler()
			if tg then tg(e,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
		elseif te:GetCode()==EVENT_FREE_CHAIN then
			if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
		else
			local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
			if tg then tg(e,tp,teg,tep,tev,tre,tr,trp,1) end
		end
		if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
			c:CancelToGrave(false)
		else
			c:CancelToGrave(true)
			local code=te:GetHandler():GetOriginalCode()
			c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,1)
		end
		local op=te:GetOperation()
		if te:GetCode()==EVENT_CHAINING then
			local chain=Duel.GetCurrentChain()-1
			local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
			local tc=te2:GetHandler()
			local g=Group.FromCards(tc)
			local p=tc:GetControler()
			if op then op(e,tp,g,p,chain,te2,REASON_EFFECT,p) end
		elseif te:GetCode()==EVENT_FREE_CHAIN then
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
		else
			local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
			if op then op(e,tp,teg,tep,tev,tre,tr,trp) end
		end
	end
end
