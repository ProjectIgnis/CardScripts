--ヴォルテクス・カオス・シューター
--Vortex Chaos Shooter
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160020051}
function s.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter(c,e,tp)
	return (c:IsCode(160020051) or s.sfilter2(c)) and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local td=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
	Duel.HintSelection(td)
	if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)<=0 then return end
	local g2=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #g2>1 then
		Duel.SortDeckbottom(tp,tp,#g2)
	end
	--Effect
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil)
	if #sg>0 then
		Duel.BreakEffect()
		local tg=aux.SelectUnselectGroup(sg,1,tp,1,2,s.rescon2,1,tp)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end
function s.sfilter(c,e,tp)
	return (c:IsCode(160020051) or s.sfilter2(c)) and c:IsAbleToHand()
end
function s.sfilter2(c,e,tp)
	return c:IsMonster() and c:IsRace(RACE_GALAXY) and c:IsType(TYPE_NORMAL) and c:IsAttack(1600)
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_GRAVE,0,1,sg,e,tp)
end
function s.rescon2(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,160020051)<2 and sg:FilterCount(s.sfilter2,nil)<2
end