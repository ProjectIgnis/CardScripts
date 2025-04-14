--錬金釜－カオス・ディスティル
--Chaos Distill
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Any card sent to your GY is banished instead
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_IGNORE_RANGE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ALL,0)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetTarget(function(e,c) return c:IsOwner(e:GetHandlerPlayer()) end)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
local CARD_MACRO_COSMOS=30241314
s.listed_names={CARD_MACRO_COSMOS,id}
function s.macrofilter(c)
	return (c:IsCode(CARD_MACRO_COSMOS) or c:ListsCode(CARD_MACRO_COSMOS)) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.monsterfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetTextAttack()==-2 and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.macrofilter,tp,LOCATION_DECK,0,1,nil)
	local c=e:GetHandler()
	local b2=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MACRO_COSMOS),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==2 then
		Duel.Remove(c,POS_FACEUP,REASON_COST)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local thfilter=(e:GetLabel()==1 and s.macrofilter or s.monsterfilter)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
