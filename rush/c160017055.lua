--スパイスクロース・ミックス
--Spice Cross Mix
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,nil,s.matfilter,nil,nil,nil,s.stage2)
end
function s.matfilter(c)
	return c:IsMonster() and c:IsRace(RACE_CYBERSE) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		if Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
			if #g==0 then return end
			Duel.HintSelection(g)
			Duel.BreakEffect()
			local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			if opt==0 then
				Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
			elseif opt==1 then
				Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end