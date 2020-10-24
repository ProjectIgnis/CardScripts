--スプリガンズ・ウォッチ
--Sprigguns Watch
--Scripted by Hatter

local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Vast Desert Gold Golgonda" from deck
	--Or add 1 "Spriggun" monster from deck, and if you do, send 1 "Spriggun" monster from deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x258}
s.listed_names={101103055}

function s.fcfilter(c)
	return c:IsCode(101103055) and c:IsAbleToHand()
end
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x258) and c:IsAbleToGrave()
end
function s.mcfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x258) and c:IsAbleToHand() 
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_DECK,0,1,nil)
			or (Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,101103055),tp,LOCATION_FZONE,0,1,nil) 
			and Duel.IsExistingMatchingCard(s.mcfilter,tp,LOCATION_DECK,0,1,nil,tp))
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_DECK,0,1,nil)
	local b=Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,101103055),tp,LOCATION_FZONE,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.mcfilter,tp,LOCATION_DECK,0,1,nil,tp)
	if not a and not b then return end
	if (not a and b) or (b and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.mcfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local cg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #cg>0 then Duel.SendtoGrave(cg, REASON_EFFECT) end
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.GetFirstMatchingCard(s.fcfilter,tp,LOCATION_DECK,0,nil)
		if g then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end