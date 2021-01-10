--紅蓮薔薇の魔女
--Bloodrose Witch
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Tribute + search + deck stack + potentially Normal Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--To Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tedtg)
	e2:SetOperation(s.tedop)
	c:RegisterEffect(e2)
end
s.listed_names={id,17720747,CARD_BLACK_ROSE_DRAGON,101104035}
--Tribute + search + deck stack + potentially Normal Summon
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsCode(17720747)
end
function s.filter(c)
	return c:IsRace(RACE_PLANT) and c:IsLevelBelow(3)
end
function s.sfilter(c)
	return c:IsCode(17720747) and c:IsSummonable(true,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_EFFECT)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) then
			Duel.ConfirmCards(1-tp,g)
			local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if tc then
				Duel.ShuffleDeck(tp)
				Duel.MoveSequence(tc,0)
				Duel.ConfirmDecktop(tp,1)
			end
		else Duel.ConfirmCards(1-tp,g)
		end
	end
	local g2=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		if tc then
			Duel.Summon(tp,tc,true,nil)
		end
	end
end
--To Extra Deck
function s.tedfilter(c,tp)
	return (c:IsCode(73580471) or c:IsCode(101104035)) and c:IsAbleToExtra()
end
function s.tedtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tedfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.tedop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tedfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.SendtoDeck(tc,tp,2,REASON_EFFECT)
	end
end
