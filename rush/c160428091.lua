--ピーキング・マジシャン
--Peeking Magician
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Each player excavates 2 cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=2
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)~=1 then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 then
		Duel.ConfirmDecktop(tp,2)
		Duel.SortDecktop(tp,tp,2)
	end
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=2 then
		Duel.ConfirmDecktop(1-tp,2)
		Duel.SortDecktop(1-tp,1-tp,2)
	end
end