--レベル・チェンジ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x41}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()~=tp  
end
function s.costfilter(c,e,tp,ft)
	if not c:IsSetCard(0x41) or not c:IsAbleToGraveAsCost() then return false end
	local class=c:GetMetatable(true)
	return (ft>0 or c:GetSequence()<5) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,class,e,tp)
end
function s.spfilter(c,class,e,tp)
	local code=c:GetCode()
	for i=1,#class.listed_names do
		if code==class.listed_names[i] then	return c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	end
	return false
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return ft>-1 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
	Duel.SendtoGrave(g,REASON_COST)
	Duel.SetTargetParam(g:GetFirst():GetCode())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local class=Duel.GetMetatable(code)
	if class==nil or class.listed_names==nil then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,class,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
