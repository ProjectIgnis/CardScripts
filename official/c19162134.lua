--エンタメデュエル
--Dueltaining
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Draw 2 cards (Special Summon 5 monsters)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon(0))
	e2:SetOperation(s.drop(0))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCondition(s.spcon(1))
	e3:SetOperation(s.drop(1))
	c:RegisterEffect(e3)
	--Draw 2 cards (Battled 5 times)
	local e4=e2:Clone()
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(s.btcon(0))
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_BATTLED)
	e5:SetCondition(s.btcon(1))
	c:RegisterEffect(e5)
	--Draw 2 cards (Chain Link 5 or higher)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_FZONE)
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	local e6=e2:Clone()
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetCondition(s.chcon(0))
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetCode(EVENT_CHAIN_SOLVING)
	e7:SetCondition(s.chcon(1))
	c:RegisterEffect(e7)
	--Draw 2 cards (Coin/dice tossed 5 times)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_TOSS_COIN)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetRange(LOCATION_FZONE)
	e8:SetOperation(s.tossop)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_TOSS_DICE)
	e9:SetOperation(s.diceop)
	c:RegisterEffect(e9)
	--Draw 2 cards (Damage made LP 500 or lower)
	local ea=e2:Clone()
	ea:SetCode(EVENT_DAMAGE)
	ea:SetCondition(s.damcon(0))
	c:RegisterEffect(ea)
	local eb=e3:Clone()
	eb:SetCode(EVENT_DAMAGE)
	eb:SetCondition(s.damcon(1))
	c:RegisterEffect(eb)
end
function s.draw(tp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Draw(tp,2,REASON_EFFECT)
end
function s.spcon(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return #eg==5 and eg:IsExists(Card.IsSummonPlayer,1,nil,tp~p) and eg:GetClassCount(Card.GetLevel)==5
	end
end
function s.drop(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		s.draw(tp~p)
	end
end
function s.btcon(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local a=Duel.GetBattleMonster(tp~p)
		if a then
			a:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CONTROL|RESET_PHASE|PHASE_END,0,1)
			return a:GetFlagEffect(id)==5
		else return false end
	end
end
function s.chcon(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return rp==(tp~p) and Duel.GetCurrentChain()>=5 and e:GetHandler():GetFlagEffect(1)>0
	end
end
function s.tossop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local count=aux.GetCoinCountFromEv(ev)
	local flag_id=id+(ep==tp and 1 or 2)
	for i=1,count do
		c:RegisterFlagEffect(flag_id,RESETS_STANDARD_PHASE_END,0,1)
	end
	if c:GetFlagEffect(flag_id)>=5 and c:GetFlagEffect(flag_id+2)==0 then
		s.draw(ep)
		c:RegisterFlagEffect(flag_id+2,RESETS_STANDARD_PHASE_END,0,1)
	end
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct1=aux.GetDiceCountSelfFromEv(ev)
	local ct2=aux.GetDiceCountOppoFromEv(ev)
	if ep==tp then
		for i=1,ct1 do
			c:RegisterFlagEffect(id+1,RESETS_STANDARD_PHASE_END,0,1)
		end
		for i=1,ct2 do
			c:RegisterFlagEffect(id+2,RESETS_STANDARD_PHASE_END,0,1)
		end
	else
		for i=1,ct2 do
			c:RegisterFlagEffect(id+1,RESETS_STANDARD_PHASE_END,0,1)
		end
		for i=1,ct1 do
			c:RegisterFlagEffect(id+2,RESETS_STANDARD_PHASE_END,0,1)
		end
	end
	if c:GetFlagEffect(id+1)>=5 and c:GetFlagEffect(id+3)==0 then
		s.draw(tp~0)
		c:RegisterFlagEffect(id+3,RESETS_STANDARD_PHASE_END,0,1)
	end
	if c:GetFlagEffect(id+2)>=5 and c:GetFlagEffect(id+4)==0 then
		s.draw(tp~1)
		c:RegisterFlagEffect(id+4,RESETS_STANDARD_PHASE_END,0,1)
	end
end
function s.damcon(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		tp=tp~p
		return ep==tp and Duel.GetLP(tp)<=500 and Duel.GetLP(tp)>0
	end
end