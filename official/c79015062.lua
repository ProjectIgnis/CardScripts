--繋がり－Ａｉ－
--TA.I.es
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_IGNISTER}
function s.revfilter(c,e,tp,mmz_chk)
	if not c:IsRace(RACE_CYBERSE) or c:IsPublic() then return false end
	if c:IsAttribute(ATTRIBUTE_DARK) then
		return mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
	else
		return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
	end
end
function s.thfilter1(c)
	return c:IsAttributeExcept(ATTRIBUTE_DARK) and c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
function s.thfilter2(c,attr)
	return c:IsSetCard(SET_IGNISTER) and c:IsMonster() and c:IsAttributeExcept(attr) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil,e,tp,mmz_chk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mmz_chk):GetFirst()
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
	e:SetLabelObject(rc)
	Duel.SetTargetCard(rc)
	local category=rc:IsAttribute(ATTRIBUTE_DARK) and CATEGORY_SPECIAL_SUMMON or CATEGORY_TODECK
	Duel.SetOperationInfo(0,category,rc,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject()
	if rc:IsRelateToEffect(e) then
		local success=nil
		local thfilter=nil
		if rc:IsAttribute(ATTRIBUTE_DARK) then
			--Special Summon the revealed monster, and if you do, add 1 non-DARK Level 4 or lower Cyberse monster from your Deck to your hand
			success=Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEUP)>0
			thfilter=s.thfilter1
		else
			--Shuffle the revealed monster into the Deck, and if you do, add 1 "@Ignister" monster with a different Attribute from your Deck to your hand
			Duel.ConfirmCards(1-tp,rc)
			success=Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
			thfilter=s.thfilter2
		end
		if success then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,thfilter,tp,LOCATION_DECK,0,1,1,nil,rc:GetAttribute())
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--You cannot Special Summon for the rest of this turn after this card resolves, except Cyberse monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsRace(RACE_CYBERSE) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end