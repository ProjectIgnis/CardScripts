--ドラゴンズ・ブースト・フュージョン
--Dragon's Boost Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,nil,Fusion.OnFieldMat(aux.FaceupFilter(Card.IsRace,RACE_DRAGON)),nil,nil,nil,s.stage2)
end
s.listed_names={CARD_REDBOOT_B_DRAGON}
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCode(CARD_REDBOOT_B_DRAGON)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		local mg=tc:GetMaterial()
		local ct=mg:FilterCount(s.cfilter,nil)
		if ct>0 and Duel.IsPlayerCanDiscardDeck(tp,7) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.DiscardDeck(tp,7,REASON_EFFECT)
			local g=Duel.GetOperatedGroup()
			local ct2=g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
			if ct2>0 and Duel.IsPlayerCanDiscardDeck(1-tp,7) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.BreakEffect()
				Duel.DiscardDeck(1-tp,7,REASON_EFFECT)
			end
		end
	end
end