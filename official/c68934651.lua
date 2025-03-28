--ファイアウォール・ドラゴン・ダークフルード
--Firewall Dragon Darkfluid
--Scripted by Eerie Code
local s,id=GetID()
local COUNTER_FW=0x14c
local TYPES=TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(COUNTER_FW)
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),3)
	--counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
end
function s.ctfilter(c)
	return c:IsType(TYPES) and c:IsRace(RACE_CYBERSE)
end
local function getcount(tp)
	local tottype=0
	Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_GRAVE,0,nil):ForEach(function(c) tottype=tottype|c:GetType() end)
	tottype=tottype&(TYPES)
	local ct=0
	while tottype~=0 do
		if tottype&0x1~=0 then ct=ct+1 end
		tottype=tottype>>1
	end
	return ct
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=getcount(tp)
	if chk==0 then return ct>0 and e:GetHandler():IsCanAddCounter(COUNTER_FW,ct) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	c:AddCounter(COUNTER_FW,getcount(tp))
end
function s.atkcon(e)
	return Duel.IsBattlePhase()
end
function s.atkval(e,c)
	return c:GetCounter(COUNTER_FW)*2500
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_FW,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,COUNTER_FW,1,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if Duel.NegateActivation(ev) and c==tc and c:CanChainAttack(0)
		and c:IsRelateToEffect(e) then
		--Needed for the end of the Damage Step
		Duel.ChainAttack()
		--Make another attack in a row
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(s.chainop)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
function s.chainop(e)
	Duel.ChainAttack()
end