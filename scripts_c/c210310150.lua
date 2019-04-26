--Fluffal Lizard
--AlphaKretin
function c210310150.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37115575,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,210310150)
	e1:SetCost(c210310150.spcost)
	e1:SetTarget(c210310150.sptg)
	e1:SetOperation(c210310150.spop)
	c:RegisterEffect(e1)
end
function c210310150.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa9) and not c:IsCode(210310150) and c:IsAbleToDeckAsCost()
end
function c210310150.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210310150.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c210310150.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoDeck(g,tp,0,REASON_COST)
	Duel.ShuffleDeck(tp)
	e:SetLabel(g:GetFirst():GetCode())
end
function c210310150.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210310150.spfilter(c,e,tp,code)
	return c:IsSetCard(0xa9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code)
end
function c210310150.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=e:GetLabel()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local g=Duel.GetMatchingGroup(c210310150.spfilter,tp,LOCATION_DECK,0,nil,e,tp,code)
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(13241004,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			local tc=sg:GetFirst()
			if tc then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end