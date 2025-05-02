--Dragon Caller
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={17985575,43973174} --"Lord of D.", "The Flute of Summoning Dragon"

function s.flutethfilter(c)
	return c:IsCode(43973174) and c:IsAbleToHand()
end
function s.fluterevfilter(c)
	return c:IsCode(43973174) and not c:IsPublic()
end
function s.lordofdthfilter(c)
	return c:IsCode(17985575) and c:IsAbleToHand()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--Condition (Add "The Flute of Summoning Dragon" from your Deck to your hand)
	local b1=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,17985575),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.flutethfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	--Condition (Add "Lord of D." from your Deck or GY to your hand)
	local b2=Duel.IsExistingMatchingCard(s.fluterevfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.lordofdthfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0 and (b1 or b2)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Check (Add "The Flute of Summoning Dragon" from your Deck or GY to your hand)
	local b1=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,17985575),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.flutethfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	--Check (Add "Lord of D." from your Deck or GY to your hand)
	local b2=Duel.IsExistingMatchingCard(s.fluterevfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.lordofdthfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	if op==1 then
		--Add 1 "The Flute of Summoning Dragon" from your Deck or GY to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.flutethfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		--Add 1 "Lord of D." from your Deck to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g1=Duel.SelectMatchingCard(tp,s.fluterevfilter,tp,LOCATION_HAND,0,1,1,nil)
		if #g1>0 then
			Duel.ConfirmCards(1-tp,g1)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.lordofdthfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
			if #g2>0 then
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g2)
			end
		end
	end
end
