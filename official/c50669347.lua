--守護神-ネフティス
--Nephthys, the Sacred Preserver
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 "Nephthys" monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_NEPHTHYS),2)
	--During your Main Phase, if this card was Link Summoned: You can activate 1 of these effects;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NEPHTHYS}
function s.deckthfilter(c)
	return c:IsLevel(8) and c:IsRace(RACE_WINGEDBEAST) and c:IsAbleToHand()
end
function s.desfilter(c,e,tp)
	return c:IsSetCard(SET_NEPHTHYS) and c:IsMonster() and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalCodeRule())
end
function s.spfilter(c,e,tp,code)
	return c:IsSetCard(SET_NEPHTHYS) and not c:IsOriginalCodeRule(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Add 1 Level 8 Winged Beast monster from your Deck to your hand, then you can add 1 Ritual Spell from your GY to your hand
	local b1=Duel.IsExistingMatchingCard(s.deckthfilter,tp,LOCATION_DECK,0,1,nil)
	--● Destroy 1 "Nephthys" monster this card points to, and Special Summon 1 "Nephthys" monster with a different original name from your GY, but negate its effects
	local lg=e:GetHandler():GetLinkedGroup()
	local b2=lg:IsExists(s.desfilter,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,lg,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.gythfilter(c)
	return c:IsRitualSpell() and c:IsAbleToHand()
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Add 1 Level 8 Winged Beast monster from your Deck to your hand, then you can add 1 Ritual Spell from your GY to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local dc=Duel.SelectMatchingCard(tp,s.deckthfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if dc and Duel.SendtoHand(dc,nil,REASON_EFFECT)>0 and dc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,dc)
			Duel.ShuffleHand(tp)
			if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.gythfilter),tp,LOCATION_GRAVE,0,1,nil)
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gythfilter),tp,LOCATION_GRAVE,0,1,1,nil)
				if #g>0 then
					Duel.HintSelection(g)
					Duel.BreakEffect()
					Duel.SendtoHand(g,nil,REASON_EFFECT)
				end
			end
		end
	elseif op==2 then
		--● Destroy 1 "Nephthys" monster this card points to, and Special Summon 1 "Nephthys" monster with a different original name from your GY, but negate its effects
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local lg=c:GetLinkedGroup()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dc=lg:FilterSelect(tp,s.desfilter,1,1,nil,e,tp):GetFirst()
		if not dc then return end
		Duel.HintSelection(dc)
		if Duel.Destroy(dc,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,dc:GetOriginalCodeRule()):GetFirst()
			if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				--Negate its effects
				sc:NegateEffects(c)
			end
			Duel.SpecialSummonComplete()
		end
	end
end