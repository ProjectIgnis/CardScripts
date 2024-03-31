--ＣＡＮ－Ｉ：Ｄ
--CAN - I:D
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Level 7 Psychic monster from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	return #g>0 and not g:IsExists(aux.NOT(Card.IsRace),1,nil,RACE_PSYCHIC|RACE_OMEGAPSYCHIC)
end
function s.cfilter(c,e,tp)
	return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_PSYCHIC) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g==0 or Duel.SendtoGrave(g,REASON_COST)==0 then return end
	--Effect
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #rg>0 and Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_CAN_D)
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.BreakEffect()
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		e1:SetValue(700)
		c:RegisterEffect(e1)
	end
end
