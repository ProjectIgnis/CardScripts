--Stay Force
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local label=e:GetLabel()
	if chk==0 then
		e:SetLabel(0)
		return true
	end
	local ct=Duel.GetCurrentChain()
	if ct==1 then return end
	local ct=Duel.GetCurrentChain()
	local te,p=Duel.GetChainInfo(ct-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local g=Group.FromCards(te:GetHandler())
	if s.discon(e,tp,g,p,ct-1,te,REASON_EFFECT,p) and (label~=1 or s.discost(e,tp,g,p,ct-1,te,REASON_EFFECT,p,0)) 
		and s.distg(e,tp,g,p,ct-1,te,REASON_EFFECT,p,0) and Duel.SelectYesNo(tp,94) then
		if label==1 then s.discost(e,tp,g,p,ct-1,te,REASON_EFFECT,p,1) end
		e:SetCategory(CATEGORY_DISABLE)
		e:SetOperation(s.disop)
		s.distg(e,tp,g,p,ct-1,te,REASON_EFFECT,p,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.GetCurrentPhase()~=PHASE_END or not re:IsActiveType(TYPE_MONSTER) or not rc:IsLocation(LOCATION_MZONE) 
		or rc:IsControler(1-tp) or not Duel.IsChainDisablable(ev) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if ex and tg and tg:IsContains(rc) then return true end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_RELEASE)
	if ex and tg and tg:IsContains(rc) then return true end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	if ex and tg and tg:IsContains(rc) then return true end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	if ex and tg and tg:IsContains(rc) then return true end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	if ex and tg and tg:IsContains(rc) then return true end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	return ex and tg and tg:IsContains(rc)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetTargetCard(eg)
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		if tc then
			if not tc:IsRelateToEffect(e) then return end
		else
			tc=re and re:GetHandler()
			if not tc or not tc:IsRelateToEffect(re) then return end
		end
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
end
