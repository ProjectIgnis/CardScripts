--黒魔術の秘儀
--Dark Magic Secrets
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Fusion
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.fusiontg)
	e1:SetOperation(s.fusionop)
	c:RegisterEffect(e1)
	--Ritual
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(s.ritualtg)
	e2:SetOperation(s.ritualop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_MAGICIAN_GIRL}
function s.rFilter(c,e,tp,m,ft)
	if not c:IsRitualMonster() or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c.ritual_custom_condition then
		return c.ritual_custom_condition(mg,ft,"greater")
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	end
	local g=mg:Filter(Card.IsCode,nil,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL)
	if ft>0 then
		return g:IsExists(s.dmfilter,1,nil,tp,mg,c)
	else
		return mg:IsExists(s.rFilterF,1,nil,tp,mg,c,g)
	end
end
function s.rFilterF(c,tp,mg,rc,g)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		return g:IsExists(s.dmfilter,1,nil,tp,mg,rc,c)
	else return false end
end
function s.dmfilter(c,tp,mg,rc,fc)
	local g=Group.FromCards(c,fc)
	Duel.SetSelectedCard(g)
	return mg:CheckWithSumGreater(Card.GetRitualLevel,rc:GetOriginalLevel(),rc)
end
function s.ritualtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return ft>-1 and Duel.IsExistingMatchingCard(s.rFilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg,ft)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.ritualop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.rFilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg,ft):GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		local mat=nil
		if tc.ritual_custom_operation then
			tc:ritual_custom_operation(mg,"greater")
			mat=tc:GetMaterial()
		else
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			end
			local g=mg:Filter(Card.IsCode,nil,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL)
			if ft>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				local matdm=g:FilterSelect(tp,s.dmfilter,1,1,nil,tp,mg,tc)
				Duel.SetSelectedCard(matdm)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetOriginalLevel(),tc)
				mat:Merge(matdm)
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				mat=mg:FilterSelect(tp,s.rFilterF,1,1,nil,tp,mg,tc,g)
				local matdm=Group.CreateGroup()
				if not mat:IsExists(Card.IsCode,nil,1,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
					matdm=g:FilterSelect(tp,s.dmfilter,1,1,nil,tp,mg,tc,mat:GetFirst())
				end
				mat:Merge(matdm)
				Duel.SetSelectedCard(mat)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetOriginalLevel(),tc)
				mat:Merge(mat2)
			end
			tc:SetMaterial(mat)
		end
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf,g)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and #g>0 and g:IsExists(s.filter3,1,nil,m,c,chkf)
end
function s.filter3(c,m,fusc,chkf)
	return fusc:CheckFusionMaterial(m,c,chkf)
end
function s.fusiontg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf,mg1:Filter(Card.IsCode,nil,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL))
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf,mg2:Filter(Card.IsCode,nil,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL))
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusionop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf,mg1:Filter(Card.IsCode,nil,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL))
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf,mg2:Filter(Card.IsCode,nil,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL))
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local g=mg1:Filter(Card.IsCode,nil,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL):FilterSelect(tp,s.filter3,1,1,nil,mg1,tc,chkf)
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,g,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local g=mg2:Filter(Card.IsCode,nil,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL):FilterSelect(tp,s.filter3,1,1,nil,mg2,tc,chkf)
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end

