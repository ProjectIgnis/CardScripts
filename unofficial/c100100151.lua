--スピード・ブースター
--Speed Booster
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.sctg(tp)
	if not Duel.GetFieldCard(1-tp,LOCATION_FZONE,0) or not Duel.GetFieldCard(tp,LOCATION_FZONE,0) then return false end
	local tc1=Duel.GetFieldCard(tp,LOCATION_FZONE,0):GetCounter(0x91)
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0):GetCounter(0x91)
	return tc1>tc2
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.sctg(tp) end
	Duel.SetTargetCard(Duel.GetAttacker())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.NegateAttack()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.sctg(tp) end
	local tc1=Duel.GetFieldCard(tp,LOCATION_FZONE,0):GetCounter(0x91)
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0):GetCounter(0x91)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,(tc1-tc2)*100)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc1=Duel.GetFieldCard(tp,LOCATION_FZONE,0):GetCounter(0x91)
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0):GetCounter(0x91)
	if tc1>tc2 then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,(tc1-tc2)*100,REASON_EFFECT)
	end
end