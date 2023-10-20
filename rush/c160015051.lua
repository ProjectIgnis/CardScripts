--サイクイップ・フュージョン
--Psyquip Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,nil,Fusion.OnFieldMat(aux.FaceupFilter(Card.IsRace,RACE_PSYCHIC)),nil,nil,nil,s.stage2)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WIND)
end
function s.thfilter(c)
	return c:IsEquipSpell() and c:IsAbleToHand()
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end