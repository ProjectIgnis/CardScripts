--ペンデュラム・エクシーズ
--Pendulum XYZ
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.spfilter(c,mg,lv)
	mg:ForEach(function(mc)
		mc:AssumeProperty(ASSUME_TYPE,mc:GetOriginalType())
		mc:AssumeProperty(ASSUME_LEVEL,lv)
	end)
	return c:IsXyzSummonable(nil,mg,2,2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local pg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
		if #pg~=2 then return false end
		local lv1=pg:GetFirst():GetLevel()
		local lv2=pg:GetNext():GetLevel()
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,pg,lv1) 
			or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,pg,lv2)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local pg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #pg~=2 then return false end
	local lv1=pg:GetFirst():GetLevel()
	local lv2=pg:GetNext():GetLevel()
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,pg,lv1)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,pg,lv2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=(g1+g2):Select(tp,1,1,nil):GetFirst()
	if xyz then
		if not s.spfilter(xyz,pg,lv1) then s.spfilter(xyz,pg,lv2) end
		Duel.XyzSummon(tp,xyz,nil,pg)
	end
end
