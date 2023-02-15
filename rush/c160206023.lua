--大行進前夜
--Eve of the Big March
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Add excavated monster to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEAST) and c:IsLevelAbove(7) and not c:IsPublic()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsRace(RACE_BEAST) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	--Effect
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	local ft=Duel.GetMZoneCount(tp)
	if ft>0 then
		if ft>=2 then ft=2 end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if g:IsExists(s.spfilter,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=g:FilterSelect(tp,s.spfilter,1,ft,nil,e,tp)
			if #tg>0 then
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
				g:RemoveCard(tg)
			end
		end
	end
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
end
