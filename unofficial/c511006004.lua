--修行王国トレーニング・ワールド
--Training Grounds
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(id)
	e2:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function s.lvfilter(c,se)
	return c:GetLevel()>6 and c:IsSummonable(false,se)
end
function s.discardfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.filter(c,se,tp)
	return s.lvfilter(c,se) and Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,2,c) 
end
function s.filter2(c,se,tp)
	return s.discardfilter(c) and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_HAND,0,1,c,se) 
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local se=e:GetLabelObject()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,se,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND,0,1,1,nil,se,tp)
	Duel.SendtoGrave(g1,REASON_COST)
	local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND,0,1,1,nil,se,tp)
	Duel.SendtoGrave(g2,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local se=e:GetLabelObject()
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_HAND,0,1,nil,se) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local se=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_HAND,0,1,1,nil,se):GetFirst()
	if tc then
		Duel.Summon(tp,tc,false,se)
	end
end
