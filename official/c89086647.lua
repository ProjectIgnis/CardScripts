--お菊さんの皿算用
--Okiku's Dish Count
--scripted by pyrQ
local COUNTER_DISH=0x216
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_DISH)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Place Dish Counters on this card equal to the Chain Link number of this effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SetOperationInfo(0,CATEGORY_COUNTER,e:GetHandler(),Duel.GetCurrentChain(),tp,COUNTER_DISH) end)
	e1:SetOperation(function(e) e:GetHandler():AddCounter(COUNTER_DISH,Duel.GetCurrentChain()) end)
	c:RegisterEffect(e1)
	--● 9 or less: Your opponent cannot target this card with card effects, also it cannot be destroyed by your opponent's card effects
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetCondition(function(e) return e:GetHandler():GetCounter(COUNTER_DISH)<=9 end)
	e2a:SetValue(aux.tgoval)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2b:SetValue(aux.indoval)
	c:RegisterEffect(e2b)
	--● 10 or more: Send this card to the GY
	local e2c=Effect.CreateEffect(c)
	e2c:SetType(EFFECT_TYPE_SINGLE)
	e2c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2c:SetCode(EFFECT_SELF_TOGRAVE)
	e2c:SetRange(LOCATION_SZONE)
	e2c:SetCondition(function(e) return e:GetHandler():GetCounter(COUNTER_DISH)>=10 end)
	c:RegisterEffect(e2c)
	--Send the top 10 cards of your Deck to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsReason(REASON_EFFECT) and rp==PLAYER_NONE end)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,10) end Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,10) end)
	e3:SetOperation(function(e,tp) Duel.DiscardDeck(tp,10,REASON_EFFECT) end)
	c:RegisterEffect(e3)
end
s.counter_place_list={COUNTER_DISH}