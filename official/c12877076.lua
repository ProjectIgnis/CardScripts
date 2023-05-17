--宝玉神覚醒
--Awakening of the Crystal Ultimates
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CRYSTAL_BEAST,SET_ULTIMATE_CRYSTAL,SET_RAINBOW_BRIDGE}
s.listed_names={40854824}
local LOCATION_HAND_DECK_GRAVE_SZONE=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_SZONE
function s.cfilter(c)
	return c:IsSetCard(SET_ULTIMATE_CRYSTAL) and c:IsMonster() and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local reveal=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
	local control=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ULTIMATE_CRYSTAL),tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return reveal or control end
	if reveal and (not control or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.thfilter(c)
	return (c:IsSetCard(SET_RAINBOW_BRIDGE) or c:IsCode(40854824)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsOriginalType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND_DECK_GRAVE_SZONE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b1 and b2 and e:GetLabel()==0,aux.Stringid(id,3)})
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND_DECK_GRAVE_SZONE)
	elseif op==3 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND_DECK_GRAVE_SZONE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	e:SetLabel(op)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND_DECK_GRAVE_SZONE,0,1,nil,e,tp)
	local break_chk=false
	if b1 and (opt==1 or opt==3) then
		break_chk=true
		--Take 1 "Rainbow Bridge" card or 1 "Rainbow Refraction" and either add it to your hand or send it to the GY
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc then
			aux.ToHandOrElse(tc,tp)
		end
	end
	if b2 and (opt==2 or opt==3) then
		--Special Summon 1 "Crystal Beast" Monster Card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND_DECK_GRAVE_SZONE,0,1,1,nil,e,tp)
		if #g>0 then
			if break_chk then Duel.BreakEffect() end
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
