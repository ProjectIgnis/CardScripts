--エクソシスター・パークス
--Exosister Pax
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCondition(function()return Duel.IsMainPhase()end)
	e1:SetCost(Cost.PayLP(800))
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={SET_EXOSISTER}
function s.thfilter(c)
	return c:IsSetCard(SET_EXOSISTER) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.listfilter(c,sc)
	return c:IsSetCard(SET_EXOSISTER) and c:IsFaceup() and c:IsMonster() and sc:ListsCode(c:GetCode())
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not sc or Duel.SendtoHand(sc,nil,REASON_EFFECT)<1 or not sc:IsLocation(LOCATION_HAND) then return end
	Duel.ConfirmCards(1-tp,sc)
	Duel.ShuffleHand(tp)
	if sc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.listfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,sc) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end