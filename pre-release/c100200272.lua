--ドローパン
--Drawbread
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Draw 1 card and show it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_GRAVE,0,1,nil) end)
	e1:SetCost(Cost.PayLP(200))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	Duel.ConfirmCards(1-tp,dc)
	Duel.ShuffleHand(tp)
	if not dc:IsMonster() then return end
	Duel.BreakEffect()
	if not Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,dc:GetAttribute()) then
		--Draw 1 card
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		--Discard 1 card
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
	end
end