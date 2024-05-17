--時空の七皇
--Seventh Tachyon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NUMBER}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-1)
	return true
end
function s.revfilter(c,tp)
	if not (c:IsSetCard(SET_NUMBER) and not c:IsPublic() and c:IsType(TYPE_XYZ)) then return false end
	local number=c.xyz_number
	return number and number>=101 and number<=107 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetRace(),c:GetAttribute(),c:GetRank())
end
function s.thfilter(c,race,attr,rank)
	return (c:IsRace(race) or c:IsAttribute(attr)) and c:IsLevel(rank) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==-1 and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
		e:SetLabel(0)
		return res
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	e:SetLabel(rc:GetRace(),rc:GetAttribute(),rc:GetRank())
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleExtra(tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local race,attr,rank=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,race,attr,rank):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,sc)
		Duel.ShuffleHand(tp)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local c=e:GetHandler()
	--Cannot Special Summon from the Extra Deck, except Xyz Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalType(TYPE_XYZ) end)
end