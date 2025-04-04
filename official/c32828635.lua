--エンドレス・オブ・ザ・ワールド
--Cycle of the World
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon "Ruin, Queen of Oblivion" or "Demise, King of Armageddon"
	Ritual.AddProcGreater({handler=c,filter=s.ritualfil,matfilter=s.forcedgroup})
	--Add 1 "End of the World" from your Deck to your hand, then, you can add 1 "Ruin, Queen of Oblivion" or "Demise, King of Armageddon" from your GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(aux.exccon)
	e1:SetCost(Cost.SelfToDeck)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_names={46427957,72426662,8198712} --"Ruin, Queen of Oblivion", "Demise, King of Armageddon", "End of the World"
s.fit_monster={46427957,72426662}
function s.ritualfil(c)
	return c:IsCode(46427957,72426662) and c:IsRitualMonster()
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_ONFIELD)
end
function s.deckthfilter(c)
	return c:IsCode(8198712) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.gravethfilter(c)
	return c:IsCode(46427957,72426662) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.deckthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.gravethfilter),tp,LOCATION_GRAVE,0,nil)
		if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
