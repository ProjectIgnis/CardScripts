--自動ネジマキ機
--Automatic Gearspring Machine
local s,id=GetID()
local COUNTER_GEARSPRING=0x107
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_GEARSPRING)
	--When you activate this card: Place 2 Gearspring Counters on it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--During each of your Standby Phases, place 1 Gearspring Counter on this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and e:GetHandler():IsCanAddCounter(COUNTER_GEARSPRING,1) end)
	e2:SetOperation(s.standbycounterop)
	c:RegisterEffect(e2)
	--Place Gearspring Counters on another card you can place a Gearspring Counter on, equal to the number of Gearspring Counters that were on this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.maincountercost)
	e3:SetTarget(s.maincountertg)
	e3:SetOperation(s.maincounterop)
	c:RegisterEffect(e3)
end
s.counter_place_list={COUNTER_GEARSPRING}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanAddCounter(COUNTER_GEARSPRING,2,false,LOCATION_SZONE) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,2,tp,COUNTER_GEARSPRING)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:AddCounter(COUNTER_GEARSPRING,2) then
		Duel.RaiseEvent(c,EVENT_CUSTOM+511002905,e,REASON_EFFECT,tp,tp,2)
	end
end
function s.standbycounterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:AddCounter(COUNTER_GEARSPRING,1) then
		Duel.RaiseEvent(c,EVENT_CUSTOM+511002905,e,REASON_EFFECT,tp,tp,1)
	end
end
function s.maincountercost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	e:SetLabel(c:GetCounter(COUNTER_GEARSPRING))
	Duel.SendtoGrave(c,REASON_COST)
end
function s.maincountertg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local ct=c:GetCounter(COUNTER_GEARSPRING)
		return ct>0 and Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,COUNTER_GEARSPRING,ct)
	end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),tp,COUNTER_GEARSPRING)
end
function s.maincounterop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local sc=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,COUNTER_GEARSPRING,ct):GetFirst()
	if sc then
		Duel.HintSelection(sc)
		if sc:AddCounter(COUNTER_GEARSPRING,ct) then
			Duel.RaiseEvent(sc,EVENT_CUSTOM+511002905,e,REASON_EFFECT,tp,tp,ct)
		end
	end
end