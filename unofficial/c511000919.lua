--月輪鏡
--Full Moon Mirror
local s,id=GetID()
local COUNTER_FULL_MOON=0x99
function s.initial_effect(c)
	--"Full Moon Counter" enable
	c:EnableCounterPermit(COUNTER_FULL_MOON)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Each time a monster(s) is destroyed, add 1 "Full Moon Counter" to this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)	return eg:IsExists(s.ctfilter,1,nil) end)
	e1:SetOperation(function(e) e:GetHandler():AddCounter(COUNTER_FULL_MOON,1) end)
	c:RegisterEffect(e1)
	--Activate 1 "Infinite Fiend Mirror" from your hand or Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(function(e) return e:GetHandler():HasCounter(COUNTER_FULL_MOON,10) end)
	e2:SetCost(Cost.SelfTribute)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
end
s.counter_place_list={COUNTER_FULL_MOON}
s.listed_names={100000080} --"Infinite Fiend Mirror"
function s.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.actfilter(c,tp)
	return c:IsCode(100000080)  and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	Duel.ActivateFieldSpell(sc,e,tp,eg,ep,ev,re,r,rp)
end
