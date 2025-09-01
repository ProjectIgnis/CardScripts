--ヌメロン・ネットワーク (Anime)
--Numeron Network (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Activate in the opponent's turn if you control no cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_DRAW)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1)
	e2:SetCondition(s.actfromhandcon)
	e2:SetTarget(s.actfromhandtg)
	e2:SetOperation(s.actfromhandop)
	c:RegisterEffect(e2)
	--"Numeron" Xyz Monsters you control do not have to detach materials to activate effects that require detaching materials
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
				local rc=re:GetHandler()
				return (r&REASON_COST)>0 and re:IsActivated()
					and re:IsActiveType(TYPE_XYZ) and rc:IsSetCard(SET_NUMERON)
					and ep==e:GetOwnerPlayer() and ev>=1 and rc:GetOverlayCount()>=ev-1
			end)
	e3:SetOperation(function() Duel.Hint(HINT_CARD,0,id) return true end)
	c:RegisterEffect(e3)
	--Activate "Numeron" cards in the opponent's turn
	local e4a=Effect.CreateEffect(c)
	e4a:SetDescription(aux.Stringid(12079734,0))
	e4a:SetType(EFFECT_TYPE_QUICK_O)
	e4a:SetCode(EVENT_FREE_CHAIN)
	e4a:SetRange(LOCATION_FZONE)
	e4a:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e4a:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=1 end)
	e4a:SetTarget(s.numacttg)
	e4a:SetOperation(s.numactop)
	c:RegisterEffect(e4a)
	local e4b=Effect.CreateEffect(c)
	e4b:SetDescription(aux.Stringid(93016201,0))
	e4b:SetType(EFFECT_TYPE_QUICK_O)
	e4b:SetCode(EVENT_SPSUMMON)
	e4b:SetRange(LOCATION_FZONE)
	e4b:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e4b:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=1 end)
	e4b:SetTarget(s.numacttg)
	e4b:SetOperation(s.numactop)
	c:RegisterEffect(e4b)
	local chain=Duel.GetCurrentChain
	copychain=0
	Duel.GetCurrentChain=function()
		if copychain==1 then copychain=0 return chain()-1
		else return chain() end
	end
end
s.listed_series={SET_NUMERON}
function s.actfromhandcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
end
function s.actfromhandtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.actfromhandop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c then
		Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		Duel.RaiseEvent(c,EVENT_CHAIN_SOLVED,c:GetActivateEffect(),0,tp,tp,Duel.GetCurrentChain())
	end
end
function s.numactfilter(c,e,tp,eg,ep,ev,re,r,rp,chain,chk)
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
function s.numacttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chain=Duel.GetCurrentChain()
	if chk==0 then return Duel.IsExistingMatchingCard(s.numactfilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp,chain) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.numactop(e,tp,eg,ep,ev,re,r,rp)
	local chain=Duel.GetCurrentChain()-1
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.numactfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp,chain,true)
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
