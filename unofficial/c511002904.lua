--自動ネジマキ機
--Automatic Gearspring Machine
local GEARSPRING_COUNTER=0x107
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(GEARSPRING_COUNTER)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--During each of your Standby Phases, place 1 Gearspring Counter on this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	--Place Gearspring Counters on another card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.plcost)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,GEARSPRING_COUNTER)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(GEARSPRING_COUNTER,2)
		Duel.RaiseEvent(c,511002905,e,REASON_EFFECT,tp,tp,GEARSPRING_COUNTER)
	end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(GEARSPRING_COUNTER,1)
	Duel.RaiseEvent(c,511002905,e,REASON_EFFECT,tp,tp,GEARSPRING_COUNTER)
end
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabel(e:GetHandler():GetCounter(GEARSPRING_COUNTER))
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetCounter(GEARSPRING_COUNTER)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,GEARSPRING_COUNTER,ct)
	end
	Duel.SetTargetParam(e:GetLabel())
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,GEARSPRING_COUNTER)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,GEARSPRING_COUNTER,ct)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g,true)
		tc:AddCounter(GEARSPRING_COUNTER,ct)
		Duel.RaiseEvent(c,511002905,e,REASON_EFFECT,tp,tp,GEARSPRING_COUNTER)
	end
end
