--マジック・サンクチュアリ
--Spell Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	--Each player adds 1 Spell from their Deck to their hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--wut
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2a:SetCode(EFFECT_BECOME_QUICK)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2a:SetTarget(function(e,c) return c:IsSpell() and not c:IsType(TYPE_QUICKPLAY) and c:IsFacedown() and Duel.GetTurnPlayer()~=c:GetControler() end)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	e2b:SetTarget(function(e,c) return c:IsSpell() and not c:IsType(TYPE_QUICKPLAY) and c:IsHasEffect(EFFECT_BECOME_QUICK) and Duel.GetTurnPlayer()~=c:GetControler() end)
	c:RegisterEffect(e2b)
end
function s.filter(c)
	return c:IsSpell() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g1>0 then
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
	end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectMatchingCard(1-tp,s.filter,1-tp,LOCATION_DECK,0,1,1,nil)
	if #g2>0 then
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
		Duel.ConfirmCards(tp,g2)
	end
end
