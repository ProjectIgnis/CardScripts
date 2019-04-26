--created & coded by Lyris, art by Yu Cheng Hong
--天剣主タ七ラ
function c210410016.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCountLimit(1,210410016)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c210410016.target)
	e2:SetOperation(c210410016.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function c210410016.filter(c)
	return c:IsSetCard(0xfb2) and c:IsAbleToDeck()
end
function c210410016.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210410016.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,3,nil) end
	local g=Duel.GetMatchingGroup(c210410016.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c210410016.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c210410016.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,3,3,nil)
	if g:GetCount()>0 then
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then Duel.ShuffleHand(tp) end
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		if g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==3 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
