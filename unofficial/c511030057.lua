--機塊コーティング
--Appliancer Coating
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x57a}
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0x57a)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and re:GetHandler():IsType(TYPE_MONSTER)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.cfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.filter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x57a) and (c:GetReason()&0x41)==0x41 and c:GetPreviousControler()==tp
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.spfilter(c,e,tp,eg)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsType,TYPE_LINK),tp,LOCATION_ONFIELD,0,nil)
	if #g<=0 then return false end
	local zone=g:GetToBeLinkedZone(c,tp,true)
	return eg:IsContains(c) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.rmfilter(c)
	return c:IsType(TYPE_LINK) and c:IsLink(1) and c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(Card.IsType,nil,TYPE_LINK):Filter(Card.IsCanBeEffectTarget,nil,e)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,eg)
		and Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
		and e:GetHandler():IsAbleToRemove() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local spg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,eg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rmg=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,spg,1,0,g:GetFirst():GetLocation())
	rmg:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rmg,2,0,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local spc=tg:GetFirst()
	local rmc=tg:GetNext()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not spc:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsType,TYPE_LINK),tp,LOCATION_ONFIELD,0,nil)
	if #g>0 then
		local zone=g:GetToBeLinkedZone(spc,tp,true)
		if zone>0 and Duel.SpecialSummon(spc,0,tp,tp,true,false,POS_FACEUP,zone)>0 and rmc and rmc:IsRelateToEffect(e)
			and Duel.Remove(rmc,POS_FACEUP,REASON_EFFECT)>0 and rmc:IsLocation(LOCATION_REMOVED) then
			Duel.BreakEffect()
			Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		end
	end
end
