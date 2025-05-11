--幻壊兵ポッカ
--Demolition Soldier Pokka
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Mill and add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,160021014),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_WYRM) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.thfilter(c)
	return c:IsSpell() and c:IsType(TYPE_FIELD|TYPE_EQUIP) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	if og:FilterCount(s.cfilter,nil)>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=aux.SelectUnselectGroup(sg,1,tp,1,2,s.rescon,1,tp)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsType,nil,TYPE_EQUIP)<2 and sg:FilterCount(Card.IsType,nil,TYPE_FIELD)<2
end