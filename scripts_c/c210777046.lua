--Mountain Kon
--scripted by Naim
local cardID = c210777046
function cardID.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(cardID.spcon)
	e1:SetCountLimit(1,210777046)
	e1:SetTarget(cardID.sptg)
	e1:SetOperation(cardID.spop)
	c:RegisterEffect(e1)
	--spsummon Oracle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210777046,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(cardID.sptg2)
	e2:SetOperation(cardID.spop2)
	c:RegisterEffect(e2)
end
function cardID.cfilter(c)
	return c:IsFaceup() and ((c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_LIGHT)) or (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)))
end
function cardID.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cardID.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function cardID.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cardID.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cardID.spfilter(c,e,tp)
	return c:IsCode(42280216) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cardID.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cardID.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cardID.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cardID.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end