--幽合
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
function s.filter1(c,e)
	return c:IsOnField() and c:IsCanBeFusionMaterial() and c:IsRace(RACE_ZOMBIE) and (not e or not c:IsImmuneToEffect(e))
end
function s.filter2(c,e)
	return c:IsCanBeFusionMaterial() and c:IsRace(RACE_ZOMBIE) and (not e or not c:IsImmuneToEffect(e))
end
function s.filter3(c,e,tp,m,f,chainm)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) 
		and m:IsExists(s.matfilter1,1,nil,m,c,tp,chainm)
end
function s.matfilter1(c,m,fc,tp,chainm)
	return (c:IsOnField() or chainm) and m:IsExists(s.matfilter2,1,c,fc,tp,c,chainm)
end
function s.matfilter2(c,fc,tp,mc,chainm)
	local g=Group.FromCards(c,mc)
	return (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or chainm) and fc:CheckFusionMaterial(g,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil)
		local mg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_GRAVE+LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		local res=Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,false)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp):Filter(s.filter2,nil)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,true)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	local mg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_GRAVE+LOCATION_DECK,0,nil,e)
	mg1:Merge(mg)
	local sg1=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,false)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp):Filter(s.filter2,nil,e)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,true)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local mat1=mg1:FilterSelect(tp,s.matfilter1,1,1,nil,mg1,tc,tp,false)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local mat2=mg1:FilterSelect(tp,s.matfilter2,1,1,mat1:GetFirst(),tc,tp,mat1:GetFirst(),false)
			mat1:Merge(mat2)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local mat1=mg2:FilterSelect(tp,s.matfilter1,1,1,nil,mg2,tc,tp,true)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local mat2=mg2:FilterSelect(tp,s.matfilter2,1,1,mat1:GetFirst(),tc,tp,mat1:GetFirst(),true)
			mat1:Merge(mat2)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat1)
		end
		tc:CompleteProcedure()
	end
end
