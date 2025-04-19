-- 背番号99 球児皇龍ホームグランドラ
--Player #99: Grand Slam Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UNIFORM_39}
function s.tdfilter(c,tp)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE)	and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_UNIFORM_39) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,c,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spfilter2(c,e,tp)
	return c:IsCode(CARD_UNIFORM_39) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	local td=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_SELECT)
	Duel.HintSelection(td)
	if Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.HintSelection(g)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
			local c=e:GetHandler()
			-- Update ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(2000)
			e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,sg,e,tp)
end