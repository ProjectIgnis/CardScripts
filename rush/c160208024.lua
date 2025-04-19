--連楽鬼サンセツコントラ
--Sansetsukontra the Music Fiend
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 3 cards of deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackAbove,3000),tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsPlayerCanDraw(tp,3) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Draw(tp,3,REASON_EFFECT)
	end
end

