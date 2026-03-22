--ディパーチャー・ゾーン
--Departure Zone
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Prevent destruction by effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Draw until 6 cards in your hand instead of until 5 cards
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DRAW_COUNT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,1)
	local function get_draw(e) return Duel.GetFieldGroupCount(Duel.GetTurnPlayer(),LOCATION_HAND,0) end
	e3:SetCondition(s.drcond)
	e3:SetValue(function(e)return 6-get_draw(e) end)
	c:RegisterEffect(e3)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=1
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.DiscardDeck(tp,2,REASON_COST)
end
function s.drcond(e)
	local tp=Duel.GetTurnPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<6 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_FZONE,0,1,nil)
end