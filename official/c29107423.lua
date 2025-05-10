--紅蓮薔薇の魔女
--Ruddy Rose Witch
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Witch of the Black Rose" from your Deck to your hand, and if you do, take 1 Level 3 or lower Plant monster from your Deck and place it on top of your Deck, then immediately after this effect resolves, you can Normal Summon 1 "Witch of the Black Rose" from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Return 1 of your "Black Rose Dragon" or "Ruddy Rose Dragon" that is banished or in your GY to the Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.textg)
	e2:SetOperation(s.texop)
	c:RegisterEffect(e2)
end
s.listed_names={17720747,CARD_BLACK_ROSE_DRAGON,40139997} --"Witch of the Black Rose", "Ruddy Rose Dragon"
function s.thfilter(c,tp)
	return c:IsCode(17720747) and c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.topdeckfilter,tp,LOCATION_DECK,0,1,c)
end
function s.topdeckfilter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_PLANT)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.sumfilter(c)
	return c:IsCode(17720747) and c:IsSummonable(true,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,sc)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local topc=Duel.SelectMatchingCard(tp,s.topdeckfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if topc then
			Duel.ShuffleDeck(tp)
			Duel.MoveSequence(topc,0)
			Duel.ConfirmDecktop(tp,1)
			if Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil)
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
				local sumc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
				if sumc then
					Duel.Summon(tp,sumc,true,nil)
				end
			end
		end
	end
end
function s.texfilter(c)
	return c:IsCode(CARD_BLACK_ROSE_DRAGON,40139997) and c:IsFaceup() and c:IsAbleToExtra()
end
function s.textg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.texfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.texop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.texfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
