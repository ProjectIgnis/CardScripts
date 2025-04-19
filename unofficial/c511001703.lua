--Flower Stacking (anime)
local s,id=GetID()
function s.initial_effect(c)
	--arrange
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0xe6}
function s.filter(c)
	return c:IsMonster() and c:IsSetCard(SET_FLOWER_CARDIAN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,3,3,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.SetTargetCard(	g)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local ct=#g
	if ct>0 then
		Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(g)
		Duel.SortDecktop(tp,tp,ct)
	end
end