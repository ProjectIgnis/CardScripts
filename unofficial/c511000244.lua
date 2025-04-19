--究極封印解放儀式術
--Ultimate Ritual of the Forbidden Lord
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(0,EFFECT_FLAG2_FORCE_ACTIVATE_LOCATION)
	e1:SetValue(LOCATION_SZONE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Return
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.retcon)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
end
s.listed_series={0x40}
s.listed_names={13893596}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,SET_FORBIDDEN_ONE)
	return g:GetClassCount(Card.GetCode)>=5
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND,0,nil,SET_FORBIDDEN_ONE)
	Duel.ConfirmCards(1-tp,g)
end
function s.filter(c,e,tp)
	return c:IsCode(13893596) and c:IsCanBeSpecialSummoned(e,0,tp,false,c:IsOriginalCode(511000243))
end
function s.dfilter(c)
	return c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_FORBIDDEN_ONE)
	if chk==0 then
		local c=e:GetHandler()
		local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and #rg>0 and not rg:IsExists(aux.NOT(Card.IsAbleToDeck),1,nil)
			and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,2,nil)
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,rg,#rg,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_FORBIDDEN_ONE)
	Duel.SendtoDeck(rg,nil,2,REASON_EFFECT)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) or not Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,2,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND,0,2,2,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	Duel.SendtoGrave(tg,REASON_EFFECT)
	Duel.SpecialSummon(tc,0,tp,tp,false,tc:IsOriginalCode(511000243),POS_FACEUP)
	tc:CompleteProcedure()
end
function s.retfilter(c)
	return c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_RETURN) and c:GetReasonEffect()
		and not (c:GetReasonEffect():GetHandler():IsCode(13893596) or Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE)==13893596)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,13893596),tp,LOCATION_MZONE,0,1,nil)
		and eg:IsExists(aux.NecroValleyFilter(s.retfilter),1,nil)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(aux.NecroValleyFilter(s.retfilter),nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end