-- ヒート・ハイーナ
-- Heat Hyena
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Send cards from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.con(e,tp)
	return not Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsMonster),tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(Card.IsMonster),tp,0,LOCATION_MZONE,nil)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(Card.IsMonster),tp,0,LOCATION_MZONE,nil)
	Duel.DiscardDeck(tp,ct,REASON_EFFECT)
end