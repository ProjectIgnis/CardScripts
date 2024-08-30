--メタリオン・フュージョン
--Metarion Fusion
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_CYBORG),nil,nil,nil,nil,s.stage2)
end
s.listed_names={CARD_FUSION}
function s.thfilter(c,mg)
	return (c:IsCode(CARD_FUSION) or mg:IsContains(c)) and c:IsAbleToHand()
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil,mg) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,mg)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end