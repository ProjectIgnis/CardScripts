--竜華界闢
--Ryu-Ge Rising
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Ryu-Ge" monster from your Deck to your hand, then you can add 1 "Ryu-Ge" Pendulum Monster from your hand to your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Special Summon 1 "Ryu-Ge" monster from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RYU_GE}
function s.thfilter(c)
	return c:IsSetCard(SET_RYU_GE) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_HAND)
end
function s.tedfilter(c)
	return c:IsSetCard(SET_RYU_GE) and c:IsType(TYPE_PENDULUM)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)
		if Duel.IsExistingMatchingCard(s.tedfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
			local g=Duel.SelectMatchingCard(tp,s.tedfilter,tp,LOCATION_HAND,0,1,1,nil)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoExtraP(g,tp,REASON_EFFECT)
			end
		end
	end
end
function s.spconfilter(c)
	return c:IsSetCard(SET_RYU_GE) and c:IsOriginalType(TYPE_PENDULUM) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spcostfilter(c,e,tp)
	return c:IsSetCard(SET_RYU_GE) and c:IsMonster() and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalRace())
end
function s.spfilter(c,e,tp,race)
	return c:IsSetCard(SET_RYU_GE) and c:IsOriginalRace(race) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetOriginalRace())
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end