--方界雷霆
--Cubic Vajra
--scripted by pyrQ
local s,id=GetID()
local COUNTER_CUBIC=0x1038
function s.initial_effect(c)
	--Add 1 card from your Deck to your hand that has an effect that places Cubic Counter(s), then if you added a monster, inflict 800 damage to your opponent
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; Special Summon 1 "Vijam the Cubic Seed" from your GY, then you can Fusion Summon 1 "Cubic" Fusion Monster from your Extra Deck, using monsters from your hand or field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.counter_list={COUNTER_CUBIC}
s.listed_names={CARD_VIJAM}
function s.thfilter(c)
	return c:PlacesCounter(COUNTER_CUBIC) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sc)
		Duel.ShuffleHand(tp)
		Duel.ShuffleDeck(tp)
		if sc:IsMonster() then
			Duel.BreakEffect()
			Duel.Damage(1-tp,800,REASON_EFFECT)
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_VIJAM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local fusion_params={
			fusfilter=function(c)
				return c:IsSetCard(SET_CUBIC)
			end
		}
		if Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end