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
function s.filter2(c)
	local te=c:GetActivateEffect()
	return te and not (te:GetProperty()&EFFECT_FLAG_DAMAGE_STEP) and c:IsType(TYPE_FIELD)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil)
	for chc in aux.Next(sg) do
		local te=chc:GetActivateEffect()
		if te and not te:IsActivatable(tp) then
			te:SetProperty(te:GetProperty()|EFFECT_FLAG_DAMAGE_STEP)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
	for chc in aux.Next(sg) do
		local te=chc:GetActivateEffect()
		if te and te:IsActivatable(tp) then
			te:SetProperty(te:GetProperty()&~EFFECT_FLAG_DAMAGE_STEP)
		end
	end
end
