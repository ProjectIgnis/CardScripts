--化石融合－フォッシル・フュージョン
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
s.listed_series={0x521}
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and (not e or not c:IsImmuneToEffect(e))
end
function s.filter2(c,e,tp,m,f)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x521) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,nil,tp)
end
function s.fcheck(tp,sg,fc)
	if not sg then
		return true
	elseif #sg==1 then
		return sg:GetFirst():IsLocation(LOCATION_GRAVE) and sg:GetFirst():IsControler(tp)
	else
		local g=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		return #g>1 and g:IsExists(s.chk,1,nil,g,tp)
	end
end
function s.chk(c,sg,tp)
	return c:IsControler(tp) and sg:IsExists(Card.IsControler,1,c,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,69832741) then return false end
		local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		Fusion.CheckAdditional=s.fcheck
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1)
		if not res then
			local ce=Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf)
			end
		end
		Fusion.CheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,69832741) then return end
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
	Fusion.CheckAdditional=s.fcheck
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,tp)
			tc:SetMaterial(mat1)
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,tp)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	Fusion.CheckAdditional=nil
end
