--死皇帝の陵墓 (Action Field)
--Mausoleum of the Emperor (Action Field)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(id)
	e0:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e0)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
end
s.af="a"
function s.filter(c,se)
	if not c:IsSummonableCard() then return false end
	local mi,ma=c:GetTributeRequirement()
	return mi>0 and (c:IsSummonable(false,se) or c:IsMSetable(false,se))
end
function s.get_targets(se,tp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,se)
	local minct=5
	local maxct=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local mi,ma=tc:GetTributeRequirement()
		if mi>0 and mi<minct then minct=mi end
		if ma>maxct then maxct=ma end
	end
	return minct,maxct
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local se=e:GetLabelObject()
	if chk==0 then
		local mi,ma=s.get_targets(se,tp)
		if mi==5 then return false end
		return Duel.CheckLPCost(tp,mi*1000)
	end
	local mi,ma=s.get_targets(se,tp)
	local ac=0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	if mi==ma then ac=Duel.AnnounceNumber(tp,mi*1000)
	elseif ma>=2 and Duel.CheckLPCost(tp,2000) then ac=Duel.AnnounceNumber(tp,1000,2000)
	else ac=Duel.AnnounceNumber(tp,1000) end
	Duel.PayLPCost(tp,ac)
	e:SetLabel(ac/1000)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.sfilter(c,se,ct)
	if not c:IsSummonableCard() then return false end
	local mi,ma=c:GetTributeRequirement()
	return (mi==ct or ma==ct) and (c:IsSummonable(false,se) or c:IsMSetable(false,se))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ct=e:GetLabel()
	local se=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND,0,1,1,nil,se,ct)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(false,se)
		local s2=tc:IsMSetable(false,se)
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			Duel.Summon(tp,tc,false,se)
		else
			Duel.MSet(tp,tc,false,se)
		end
	end
end
