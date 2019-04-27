--Dimension Trap
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(511001283)
	c:RegisterEffect(e2)
end
function s.cfilter(c,e,tp,chk,chain)
	return not c:IsHasEffect(511001283) and s.filter(c,e,tp,chk,chain)
end
function s.filter(c,e,tp,chk,chain)
	local te,eg,ep,ev,re,r,rp=c:CheckActivateEffect(true,true,true)
	if not te and chk==1 then
		te=c:GetActivateEffect()
	end
	if te==nil or not c:IsType(TYPE_TRAP) or not c:IsAbleToRemoveAsCost() then return false end
	local target=te:GetTarget()
	if te:GetCode()==EVENT_CHAINING and chk==1 then
		if chain<=0 then return false end
		local te2,p=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		local tc=te2:GetHandler()
		local g=Group.FromCards(tc)
		eg,ep,ev,re,r,rp=g,p,chain,te2,REASON_EFFECT,p
	end
	return not target or target(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local chain=Duel.GetCurrentChain()
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp,chk,chain) end
	chain=chain-1
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,chk,chain)
	g1:Merge(g2)
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
	local tc=g2:GetFirst()
	local tpe=tc:GetType()
	if (tpe&TYPE_FIELD)~=0 then
		local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
			if fc then Duel.Destroy(fc,REASON_RULE) end
			fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(c,REASON_RULE) end
		else
			fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(c,REASON_RULE) end
		end
	end
	local te,teg,tep,tev,tre,tr,trp=tc:CheckActivateEffect(true,true,true)
	if not te then te=tc:GetActivateEffect() end
	if te:GetCode()==EVENT_CHAINING then
		if chain<=0 then return false end
		local te2,p=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		local tc=te2:GetHandler()
		local g=Group.FromCards(tc)
		teg,tep,tev,tre,tr,trp=g,p,chain,te2,REASON_EFFECT,p
		g:KeepAlive()
	end
	s[Duel.GetCurrentChain()]=te
	Duel.ClearTargetCard()
	local tg=te:GetTarget()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,teg,tep,tev,tre,tr,trp,1) end
	e:SetOperation(s.activateop(teg,tep,tev,tre,tr,trp))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetReset(RESET_CHAIN)
	e1:SetLabelObject(e)
	e1:SetOperation(s.resetop)
	Duel.RegisterEffect(e1,tp)
end
function s.activateop(teg,tep,tev,tre,tr,trp)
	return function(e,tp,eg,ep,ev,re,r,rp)
				local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				local c=e:GetHandler()
				local te=s[Duel.GetCurrentChain()]
				if not te then return end
				local tpe=te:GetHandler():GetType()
				if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
					c:CancelToGrave(false)
				else
					c:CancelToGrave(true)
					local code=te:GetHandler():GetOriginalCode()
					c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,1)
				end
				local op=te:GetOperation()
				if op then op(e,tp,teg,tep,tev,tre,tr,trp) end
				if g and (tpe&TYPE_EQUIP)>0 and not e:GetHandler():GetEquipTarget() then
					Duel.Equip(tp,e:GetHandler(),g:GetFirst())
				end
			end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		te:SetOperation(s.activate)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local c=e:GetHandler()
	local te=s[Duel.GetCurrentChain()]
	if not te then return end
	local tpe=te:GetHandler():GetType()
	if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
		c:CancelToGrave(false)
	else
		c:CancelToGrave(true)
		local code=te:GetHandler():GetOriginalCode()
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,1)
	end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	if g and (tpe&TYPE_EQUIP)>0 and not e:GetHandler():GetEquipTarget() then
		Duel.Equip(tp,e:GetHandler(),g:GetFirst())
	end
end
