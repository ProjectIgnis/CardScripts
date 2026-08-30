--真海竜騎－ダイダロス
--Levia-Dragoon - Daedalus
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 3 WATER monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),3,3)
	--Additional prcedure for "Atlantis, the Dragon City"
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),2,2,nil,aux.Stringid(CARD_ATLANTIS_THE_DRAGON_CITY,0),s.splimit)
	--This card's name becomes "Umi" while in the Monster Zone
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(CARD_UMI)
	c:RegisterEffect(e1)
	--If this card is Link Summoned: You can Special Summon 1 monster that mentions "Atlantis, the Dragon City" from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(function(e)
		return e:GetHandler():IsLinkSummoned()
	end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--During the Main Phase (Quick Effect): You can send 1 face-up "Umi" you control to the GY; discard your opponent's entire hand, and if you do, they draw the same number of cards. Neither player can activate cards or effects in response to this effect's activation
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function()
		return Duel.IsMainPhase()
	end)
	e3:SetCost(s.discardcost)
	e3:SetTarget(s.discardtg)
	e3:SetOperation(s.discardop)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_UMI,CARD_ATLANTIS_THE_DRAGON_CITY}
function s.splimit(e,se,sp,st)
	if Duel.IsPlayerAffectedByEffect(sp,CARD_ATLANTIS_THE_DRAGON_CITY) then
		local c=e:GetHandler()
		c:AssumeProperty(ASSUME_LINK,c:GetLink()-1)
		return true
	end
	return false
end
function s.spfilter(c,e,tp)
	return c:ListsCode(CARD_ATLANTIS_THE_DRAGON_CITY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.discardcostfilter(c)
	return c:IsCode(CARD_UMI) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.discardcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.discardcostfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.discardcostfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.discardtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local ct=#g
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(1-tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,g,ct,1-tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ct)
	Duel.SetChainLimit(aux.FALSE)
end
function s.discardop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		local ct=Duel.SendtoGrave(g,REASON_DISCARD|REASON_EFFECT)
		if ct==0 then return end
		Duel.Draw(1-tp,ct,REASON_EFFECT)
	end
end