--ヌメロン・ネットワーク (Anime)
--Numeron Network (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Activate in the opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_DRAW)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1)
	e2:SetCondition(s.accon)
	e2:SetTarget(s.actg)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
	--No detach cost
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(CARD_NUMERON_NETWORK)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,1)
	c:RegisterEffect(e3)
	--Activate in the opponent's turn
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(12079734,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCondition(s.numcon)
	e4:SetTarget(s.numtg)
	e4:SetOperation(s.numop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(93016201,0))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_SPSUMMON)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e5:SetCondition(s.numcon)
	e5:SetTarget(s.numtg)
	e5:SetOperation(s.numop)
	c:RegisterEffect(e5)
	local chain=Duel.GetCurrentChain
	copychain=0
	Duel.GetCurrentChain=function()
		if copychain==1 then copychain=0 return chain()-1
		else return chain() end
	end
end
s.listed_series={0x14b}
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c then
		Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		Duel.RaiseEvent(c,EVENT_CHAIN_SOLVED,c:GetActivateEffect(),0,tp,tp,Duel.GetCurrentChain())
	end
end
function s.numcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=1
end
function s.tgfilter(c,e,tp,eg,ep,ev,re,r,rp,chain,chk)
	local te=c:GetActivateEffect()
	if not c:IsSetCard(SET_NUMERON) or not c:IsAbleToGrave() or not te then return end
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
	elseif (te:GetCode()==EVENT_FREE_CHAIN and e:GetCode()==EVENT_FREE_CHAIN) 
		or (te:GetCode()==EVENT_SPSUMMON and e:GetCode()==EVENT_SPSUMMON) then
		if te:GetCode()==EVENT_SPSUMMON and chk then copychain=1 end
		return (not condition or condition(e,tp,eg,ep,ev,re,r,rp)) and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
			and (not target or target(e,tp,eg,ep,ev,re,r,rp,0))
	else
		return false
	end
end
function s.numtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chain=Duel.GetCurrentChain()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp,chain) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.numop(e,tp,eg,ep,ev,re,r,rp)
	local chain=Duel.GetCurrentChain()-1
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp,chain,true)
	local tc=g:GetFirst()
	copychain=0
	if tc and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local te=tc:GetActivateEffect()
		local cost=te:GetCost()
		local tg=te:GetTarget()
		local op=te:GetOperation()
		e:SetCategory(te:GetCategory())
		e:SetProperty(te:GetProperty())
		if te:GetCode()==EVENT_CHAINING then
			local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
			local tc=te2:GetHandler()
			local g=Group.FromCards(tc)
			local p=tc:GetControler()
			if co then co(e,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
			if tg then tg(e,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
			if op then op(e,tp,g,p,chain,te2,REASON_EFFECT,p) end
		else
			if cost then cost(e,tp,eg,ep,ev,re,r,rp,1) end
			if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
		end
	end
end