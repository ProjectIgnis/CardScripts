--Ultimate Ritual of the Forbidden Lord
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetValue(LOCATION_SZONE)
	c:RegisterEffect(e1)
end
s.listed_series={0x40}
s.listed_names={13893596}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,0x40)
	return g:GetClassCount(Card.GetCode)>=5
end
function s.costfilter(c)
	return c:IsSetCard(0x40) and c:IsDiscardable()
end
function s.tdfilter(c)
	return not c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,2,nil) 
		and #rg>0 and not rg:IsExists(s.tdfilter,1,nil)end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(rg,nil,2,REASON_COST)
	Duel.DiscardHand(tp,s.costfilter,2,2,REASON_COST+REASON_DISCARD)
end
function s.filter(c,e,tp)
	if not c:IsCode(13893596) then return false end
	local nocheck=false
	for _,te in ipairs({c:GetCardEffect(EFFECT_SPSUMMON_CONDITION)}) do
		local val=te:GetValue()
		if te:GetOwner()==c and (not val or type(val)=='number' or not val(te,e,POS_FACEUP,0)) then nocheck=true break end
	end
	return c:IsCanBeSpecialSummoned(e,0,tp,nocheck,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_TO_GRAVE)
		e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:CompleteProcedure()
	end
end
function s.retfilter(c)
	return c:IsSetCard(0x40) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_RETURN) and c:GetReasonEffect()
		and not c:GetReasonEffect():GetHandler():IsCode(13893596)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.retfilter,1,nil)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.retfilter,nil)
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end
