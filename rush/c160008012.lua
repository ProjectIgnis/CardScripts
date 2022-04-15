-- リズミカル・パフォーマー
-- Rhythmical Performer
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Send top card to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,1) end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	if not Duel.IsPlayerCanDiscardDeck(1-tp,1) or Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	-- Effect
	if Duel.DiscardDeck(1-tp,1,REASON_EFFECT)<1 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	if dc:IsLocation(LOCATION_GRAVE) and dc:IsType(TYPE_SPELL+TYPE_TRAP)
		and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
