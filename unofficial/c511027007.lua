--ロシアン・ヴァレル
--Borrel Ring
--Scripted by Playmaker 772211
local COUNTER_BR=0x15a
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BR)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Negate destruction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_ATTACK)
	e2:SetCondition(s.atcon)
	e2:SetCost(s.atcost)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
end
s.listed_series={0x10f}
function s.filter(c,tp)
	return c:IsSetCard(0x10f) and c:IsType(TYPE_LINK)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.filter,1,false,nil,nil,tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.filter,1,1,false,nil,nil,tp)
	local rating=sg:GetFirst():GetLink()
	e:SetLabel(rating)
	Duel.Release(sg,REASON_COST)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel() 
	if c:IsRelateToEffect(e) then
	   c:AddCounter(COUNTER_BR,ct)
	end
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp)
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_BR,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,COUNTER_BR,1,REASON_COST)
	if c:GetCounter(COUNTER_BR)<=0 then
		Duel.Destroy(c,REASON_EFFECT)
	end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return end
	if a:IsControler(1-tp) then
		a,d=d,a
	end
	if not a:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	a:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c:GetCounter(COUNTER_BR)*-100)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	d:RegisterEffect(e2)
end