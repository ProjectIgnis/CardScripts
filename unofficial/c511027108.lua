--ヘル・チューニング
--Hell Tuning
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(s.hlfilter,tp,LOCATION_GRAVE,0,5,nil)
end
function s.hlfilter(c)
	return c:IsSetCard(0x567) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.hlfilter,tp,LOCATION_GRAVE,0,5,eg) end
	local g=Duel.SelectMatchingCard(tp,s.hlfilter,tp,LOCATION_GRAVE,0,5,5,eg)
	Duel.Remove(g,POS_FACEUP,REASON_COST)   
end
function s.scfilter1(c,tp,mc,mg)
	return Duel.IsExistingMatchingCard(s.scfilter2,tp,LOCATION_MZONE,0,1,nil,mc,c,tp,mg)
end
function s.scfilter2(c,mc,sync,tp,mg)
	mg:AddCard(mc)
	return c:IsCanBeSynchroMaterial(sync) and sync:IsSynchroSummonable(mc,mg)
		and Duel.GetLocationCountFromEx(tp,tp,mg,sync)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=eg:GetFirst()
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.scfilter1,tp,LOCATION_EXTRA,0,1,nil,tp,sg,mg) end
	sg:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	if c:GetFlagEffect(id)==0 then return end
	c:ResetFlagEffect(id)
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	mg:AddCard(c)
	local g=Duel.GetMatchingGroup(s.scfilter1,tp,LOCATION_EXTRA,0,nil,tp,c,mg)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.SynchroSummon(tp,sc,c)
		c:SetReason(REASON_MATERIAL+REASON_SYNCHRO,true)
	end
end
