--次元融合殺
--Dimension Fusion Destruction
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
s.listed_series={0x145}
s.listed_names={6007213,32491822,69890967}
function s.filter0(c)
	return c:IsAbleToRemove()
end
function s.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x145) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil)
		if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
			local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil)
			mg1:Merge(mg2)
		end
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,6007213,32491822,69890967),tp,LOCATION_MZONE,0,1,nil)
		and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler()==e:GetOwner() then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
	end
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,tp,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2,0)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end

