--ヴァンパイア・レディ
--Vampire Lady
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) or Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local b1=Duel.IsPlayerCanDiscardDeck(tp,1)
	local b2=Duel.IsPlayerCanDiscardDeck(1-tp,1)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})
	local ct=0
	if op==1 then ct=Duel.DiscardDeck(tp,1,REASON_EFFECT) elseif op==2 then ct=Duel.DiscardDeck(1-tp,1,REASON_EFFECT) end
	local g2=Duel.GetOperatedGroup()
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.SendtoDeck(g2,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
