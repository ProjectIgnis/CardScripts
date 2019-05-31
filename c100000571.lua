--磁力融合
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={100000570}
function s.chkfilter(c,g,sg,code,...)
	if not c:IsSummonCode(nil,SUMMON_TYPE_FUSION,PLAYER_NONE,code) then return false end
	if ... then
		sg:AddCard(c)
		local res=g:IsExists(s.chkfilter,1,sg,g,sg,...)
		sg:RemoveCard(c)
		return res
	else return true end
end
function s.filter(c,tp,sg,...)
	if not c:IsReleasableByEffect() or not c:IsLocation(LOCATION_MZONE) then return false end
	sg:AddCard(c)
	local res
	if #sg<3 then
		res=Duel.CheckReleaseGroupEx(tp,s.filter,1,nil,tp,sg,...)
	else
		res=Duel.GetLocationCountFromEx(tp,tp,sg)>0 and sg:IsExists(s.chkfilter,1,nil,sg,Group.CreateGroup(),...)
	end
	sg:RemoveCard(c)
	return res
end
function s.spfilter(c,e,tp)
	return c:IsCode(100000570) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:CheckFusionMaterial()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.filter,1,nil,tp,Group.CreateGroup(),450000350,450000351,450000352) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then return end
	local sg=Group.CreateGroup()
	while #sg<3 do
		local g=Duel.SelectReleaseGroupEx(tp,s.filter,1,1,nil,tp,sg,450000350,450000351,450000352)
		if not g or #g<=0 then return end
		sg:Merge(g)
	end
	if Duel.Release(sg,REASON_EFFECT)>2 and Duel.GetLocationCountFromEx(tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		sc:SetMaterial(sg)
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
