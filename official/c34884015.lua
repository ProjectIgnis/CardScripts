--魂のペンデュラム
--Soul Pendulum
--scripted by andré
local s,id=GetID()
local COUNTER_SOUL_PENDULUM=0x200
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SOUL_PENDULUM)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Change the Pendulum Scale of each card in your Pendulum Zones by 1 (min. 1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.pendscaletg)
	e1:SetOperation(s.pendscaleop)
	c:RegisterEffect(e1)
	--Each time your Pendulum Monster(s) is Pendulum Summoned, place 1 counter on this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.countercon)
	e2:SetOperation(function(e) e:GetHandler():AddCounter(COUNTER_SOUL_PENDULUM,1) end)
	c:RegisterEffect(e2)
	--Pendulum Monsters on the field gain 300 ATK for each counter on this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(function(e,c) return c:IsType(TYPE_PENDULUM) end)
	e3:SetValue(function(e,c) return e:GetHandler():GetCounter(COUNTER_SOUL_PENDULUM)*300 end)
	c:RegisterEffect(e3)
	--During your Main Phase this turn, you can conduct 1 Pendulum Summon of a monster(s) in addition to your Pendulum Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(function(e,tp) return Pendulum.PlayerCanGainAdditionalPendulumSummon(tp,id) end)
	e4:SetCost(s.extrapendcost)
	e4:SetOperation(function(e,tp) Pendulum.GrantAdditionalPendulumSummon(e:GetHandler(),nil,tp,LOCATION_HAND|LOCATION_EXTRA,aux.Stringid(id,2),aux.Stringid(id,3),id) end)
	c:RegisterEffect(e4)
end
function s.pendscaletg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,2,nil) end
	Duel.SetTargetCard(Duel.GetFieldGroup(tp,LOCATION_PZONE,0))
end
function s.pendscaleop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local c=e:GetHandler()
	for sc in tg:Iter() do
		Duel.HintSelection(sc)
		local b1=true
		local b2=sc:GetScale()>1
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,4)},
			{b2,aux.Stringid(id,5)})
		local scale=op==1 and 1 or -1
		--Change each target's Pendulum Scale by 1 (min. 1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue(scale)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		sc:RegisterEffect(e2)
	end
end
function s.counterconfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsPendulumSummoned() and c:IsSummonPlayer(tp)
end
function s.countercon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.counterconfilter,1,nil,tp)
end
function s.extrapendcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,COUNTER_SOUL_PENDULUM,3,REASON_COST) end
	c:RemoveCounter(tp,COUNTER_SOUL_PENDULUM,3,REASON_COST)
end