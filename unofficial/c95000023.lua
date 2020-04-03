--Numeron Network
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(2)
	e2:SetValue(s.valcon)
	c:RegisterEffect(e2)
	--activate 2
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.accon)
	e3:SetCost(s.accost)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(93016201,0))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_SUMMON)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(s.accon)
	e6:SetTarget(s.accost)
	e6:SetOperation(s.acop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e8)
	local chain=Duel.GetCurrentChain
	copychain=0
	Duel.GetCurrentChain=function()
		if copychain==1 then copychain=0 return chain()-1
		else return chain() end
	end
end
s.mark=0
function s.valcon(e,re,r,rp)
	return (r&REASON_EFFECT)~=0
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=1
end
function s.cfilter(c,e,tp,eg,ep,ev,re,r,rp,chain,chk)
	local te=c:GetActivateEffect()
	if not te or not c:IsType(TYPE_SPELL+TYPE_TRAP) or not c:IsAbleToGraveAsCost() then return false end
	local condition=te:GetCondition()
	local cost=te:GetCost()
	local target=te:GetTarget()
	if te:GetCode()==EVENT_CHAINING then
		if chain<=0 then return false end
		local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
		local tc=te2:GetHandler()
		local g=Group.FromCards(tc)
		local p=tc:GetControler()
		return (not condition or condition(e,tp,g,p,chain,te2,REASON_EFFECT,p)) and (not cost or cost(e,tp,g,p,chain,te2,REASON_EFFECT,p,0)) 
			and (not target or target(e,tp,g,p,chain,te2,REASON_EFFECT,p,0))
	elseif (te:GetCode()==EVENT_SPSUMMON or te:GetCode()==EVENT_SUMMON or te:GetCode()==EVENT_FLIP_SUMMON or te:GetCode()==EVENT_FREE_CHAIN) 
		and te:GetCode()==e:GetCode() then
		if chk then copychain=1 end
		return (not condition or condition(e,tp,eg,ep,ev,re,r,rp)) and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0)) 
			and (not target or target(e,tp,eg,ep,ev,re,r,rp,0))
	else
		local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
		return res and (not condition or condition(e,tp,teg,tep,tev,tre,tr,trp)) and (not cost or cost(e,tp,teg,tep,tev,tre,tr,trp,0))
			and (not target or target(e,tp,teg,tep,tev,tre,tr,trp,0))
	end
end
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	local chain=Duel.GetCurrentChain()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp,chain) end
	chain=chain-1
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp,chain,true)
	copychain=0
	Duel.SendtoGrave(g,REASON_COST)
	Duel.SetTargetCard(g:GetFirst())
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc then
		local te=tc:GetActivateEffect()
		if not te then return end
		e:SetCategory(te:GetCategory())
		e:SetProperty(te:GetProperty())
		local co=te:GetCost()
		local tg=te:GetTarget()
		local op=te:GetOperation()
		local res,teg,tep,tev,tre,tr,trp
		if te:GetCode()==EVENT_CHAINING then
			local chain=Duel.GetCurrentChain()-1
			local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
			local tc=te2:GetHandler()
			local g=Group.FromCards(tc)
			local p=tc:GetControler()
			teg,tep,tev,tre,tr,trp=g,p,chain,te2,REASON_EFFECT,p
		elseif te:GetCode()==EVENT_SUMMON or te:GetCode()==EVENT_FLIP_SUMMON or te:GetCode()==EVENT_SPSUMMON or te:GetCode()==EVENT_FREE_CHAIN then
			teg,tep,tev,tre,tr,trp=eg,ep,ev,re,r,rp
		else
			res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
		end
		e:GetHandler():CreateEffectRelation(te)
		if co then co(e,tp,teg,tep,tev,tre,tr,trp,1) end
		if tg then tg(e,tp,teg,tep,tev,tre,tr,trp,1) end
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local etc=g:GetFirst()
		while etc do
			etc:CreateEffectRelation(te)
			etc=g:GetNext()
		end
		if op then op(e,tp,teg,tep,tev,tre,tr,trp) end
		e:GetHandler():ReleaseEffectRelation(te)
		etc=g:GetFirst()
		while etc do
			etc:ReleaseEffectRelation(te)
			etc=g:GetNext()
		end
	end
end
