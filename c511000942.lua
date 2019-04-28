--Buried Soul Talisman
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp,tid)
	return (c:GetReason()&0x21)==0x21 and c:GetTurnID()==tid
		and c:IsPreviousControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tid=Duel.GetTurnCount()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil,tp,tid)
end
function s.filter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tid=Duel.GetTurnCount()
	local dg=Group.CreateGroup()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp,tid)
	local tc=g:GetFirst()
	while tc do
		dg:AddCard(tc:GetReasonCard())
		tc=g:GetNext()
	end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	if dg:IsExists(Card.IsDestructable,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tid=Duel.GetTurnCount()
	local dg=Group.CreateGroup()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp,tid)
	local tc=g:GetFirst()
	while tc do
		dg:AddCard(tc:GetReasonCard())
		tc=g:GetNext()
	end
	dg=dg:Filter(Card.IsDestructable,nil)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sp=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #sp>0 then
		Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
	end
end
