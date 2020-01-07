--スピード・ブースター
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg1)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)	
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg2)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)	
	e3:SetCondition(s.condition2)
	e3:SetTarget(s.target3)
	e3:SetOperation(s.operation2)
	c:RegisterEffect(e3)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.condition2)
	e4:SetTarget(s.target4)
	e4:SetOperation(s.operation2)
	c:RegisterEffect(e4)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.atktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldCard(tp,LOCATION_SZONE,5) 
		and Duel.GetFieldCard(1-tp,LOCATION_SZONE,5) end
	local tc1=Duel.GetFieldCard(tp,LOCATION_SZONE,5):GetCounter(0x91)
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5):GetCounter(0x91)
	e:SetLabel(0)
	if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and tc1>tc2 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetLabel(1)
		Duel.SetTargetCard(Duel.GetAttacker())
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if not Duel.GetFieldCard(1-tp,LOCATION_SZONE,5) or not Duel.GetFieldCard(tp,LOCATION_SZONE,5) then return false end
	local tc1=Duel.GetFieldCard(tp,LOCATION_SZONE,5):GetCounter(0x91)
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5):GetCounter(0x91)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 and tc1>tc2 end
	e:SetLabel(1)
	Duel.SetTargetCard(Duel.GetAttacker())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldCard(tp,LOCATION_SZONE,5) 
		and Duel.GetFieldCard(1-tp,LOCATION_SZONE,5) end
	local tc1=Duel.GetFieldCard(tp,LOCATION_SZONE,5):GetCounter(0x91)
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5):GetCounter(0x91)
	if tc1>tc2 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam((tc1-tc2)*100)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,(tc1-tc2)*100)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	else e:SetProperty(0) end
end
function s.target4(e,tp,eg,ep,ev,re,r,rp,chk)
	if not Duel.GetFieldCard(1-tp,LOCATION_SZONE,5) or not Duel.GetFieldCard(tp,LOCATION_SZONE,5) then return false end
	local tc1=Duel.GetFieldCard(tp,LOCATION_SZONE,5):GetCounter(0x91)
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5):GetCounter(0x91)
	if chk==0 then return tc1>tc2 and e:GetHandler():GetFlagEffect(id)==0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam((tc1-tc2)*100)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,(tc1-tc2)*100)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
