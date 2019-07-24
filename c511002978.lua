--Earthbound Beginning
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		--check obsolete ruling
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DRAW)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if (r&REASON_RULE)~=0 and Duel.GetTurnCount()==1 then
		--obsolete
		Duel.RegisterFlagEffect(tp,62765383,0,0,1)
		Duel.RegisterFlagEffect(1-tp,62765383,0,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil and Duel.GetLP(tp)<=3000
end
function s.filter(c,tp)
	local te=c:GetActivateEffect()
	if not te then return false end
	return c:IsType(TYPE_FIELD) and te:IsActivatable(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(s.con)
	e2:SetOperation(s.op)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,ev/2)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
	if Duel.GetFlagEffect(tp,62765383)>0 then
		if fc then Duel.Destroy(fc,REASON_RULE) end
		fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then Duel.Destroy(fc,REASON_RULE) end
	else
		fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
	end
	local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_DECK,0,nil,TYPE_FIELD)
	local chc=sg:GetFirst()
	while chc do
		local te=chc:GetActivateEffect()
		if te and not te:IsActivatable(tp) then
			te:SetProperty(te:GetProperty()+EFFECT_FLAG_DAMAGE_STEP)
		end
		chc=sg:GetNext()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 and not Duel.GetFieldCard(tp,LOCATION_SZONE,5) then
		local tc=g:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		Duel.RaiseEvent(tc,EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
	end
	chc=sg:GetFirst()
	while chc do
		local te=chc:GetActivateEffect()
		if te and te:IsActivatable(tp) then
			te:SetProperty(te:GetProperty()-EFFECT_FLAG_DAMAGE_STEP)
		end
		chc=sg:GetNext()
	end
end
