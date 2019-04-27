--エンタメデュエル
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon1)
	e2:SetOperation(s.drop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCondition(s.spcon2)
	e3:SetOperation(s.drop2)
	c:RegisterEffect(e3)
	--
	local e4=e2:Clone()
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(s.btcon1)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_BATTLED)
	e5:SetCondition(s.btcon2)
	c:RegisterEffect(e5)
	--
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_FZONE)
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	local e6=e2:Clone()
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetCondition(s.chcon1)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetCode(EVENT_CHAIN_SOLVING)
	e7:SetCondition(s.chcon2)
	c:RegisterEffect(e7)
	--
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_TOSS_COIN)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCode(EVENT_TOSS_COIN)
	e8:SetOperation(s.tossop)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_TOSS_DICE)
	e9:SetOperation(s.diceop)
	c:RegisterEffect(e9)
	--
	local ea=e2:Clone()
	ea:SetCode(EVENT_DAMAGE)
	ea:SetCondition(s.damcon1)
	c:RegisterEffect(ea)
	local eb=e3:Clone()
	eb:SetCode(EVENT_DAMAGE)
	eb:SetCondition(s.damcon2)
	c:RegisterEffect(eb)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return #eg==5 and eg:IsExists(Card.IsSummonPlayer,1,nil,tp) and eg:GetClassCount(Card.GetLevel)==5
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return #eg==5 and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) and eg:GetClassCount(Card.GetLevel)==5
end
function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Draw(tp,2,REASON_EFFECT)
end
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Draw(1-tp,2,REASON_EFFECT)
end
function s.btcon1(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if a then
		a:RegisterFlagEffect(id,RESET_EVENT+0x3fe0000+RESET_PHASE+PHASE_END,0,1)
		return a:GetFlagEffect(id)==5
	else return false end
end
function s.btcon2(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a:IsControler(tp) then a,d=d,a end
	if a then
		a:RegisterFlagEffect(id,RESET_EVENT+0x3fe0000+RESET_PHASE+PHASE_END,0,1)
		return a:GetFlagEffect(id)==5
	else return false end
end
function s.chcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and Duel.GetCurrentChain()>=5 and e:GetHandler():GetFlagEffect(1)>0
end
function s.chcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.GetCurrentChain()>=5 and e:GetHandler():GetFlagEffect(1)>0
end
function s.tossop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp then
		for i=1,ev do
			c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	else
		for i=1,ev do
			c:RegisterFlagEffect(19162136,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end
	if c:GetFlagEffect(id+1)>=5 and c:GetFlagEffect(19162137)==0 then
		s.drop1(e,tp,eg,ep,ev,re,r,rp)
		c:RegisterFlagEffect(19162137,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	if c:GetFlagEffect(19162136)>=5 and c:GetFlagEffect(19162138)==0 then
		s.drop2(e,tp,eg,ep,ev,re,r,rp)
		c:RegisterFlagEffect(19162138,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct1=(ev&0xffff)
	local ct2=(ev>>16)
	if ep==tp then
		for i=1,ct1 do
			c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		for i=1,ct2 do
			c:RegisterFlagEffect(19162136,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	else
		for i=1,ct2 do
			c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		for i=1,ct1 do
			c:RegisterFlagEffect(19162136,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end
	if c:GetFlagEffect(id+1)>=5 and c:GetFlagEffect(19162137)==0 then
		s.drop1(e,tp,eg,ep,ev,re,r,rp)
		c:RegisterFlagEffect(19162137,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	if c:GetFlagEffect(19162136)>=5 and c:GetFlagEffect(19162138)==0 then
		s.drop2(e,tp,eg,ep,ev,re,r,rp)
		c:RegisterFlagEffect(19162138,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetLP(tp)<=500
end
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.GetLP(1-tp)<=500
end
