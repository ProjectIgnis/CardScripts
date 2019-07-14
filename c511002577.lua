--Element Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_DECK)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={74711057,95486586,46759931}
function s.filter0(c,tp)
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsCode(74711057) and c:IsCanBeFusionMaterial()
end
function s.filter1(c,e,tp)
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsCode(74711057) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.filter2(c)
	return c:IsSetCard(0x3008) and c:IsFaceup() and c:IsCanBeFusionMaterial()
end
function s.filter3(c,e)
	return c:IsSetCard(0x3008) and c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.fusfilter(c,e,tp,m1,m2,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and (c:IsCode(95486586) or c:IsCode(46759931))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and m1:IsExists(s.filterx,1,nil,m2,chkf,c)
		and (c:IsControler(tp) or c:GetFlagEffect(id)>0)
end
function s.fusfilter2(c,e,tp,m1,m2,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and (c:IsCode(95486586) or c:IsCode(46759931))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and m1:IsExists(s.filterx,1,nil,m2,chkf,c)
end
function s.filterx(c,m2,chkf,fus)
	return fus:CheckFusionMaterial(m2,c,chkf)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and PLAYER_NONE or tp
		local mga1=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
		local mga2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
		local res=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,LOCATION_EXTRA,1,nil,e,tp,mga1,mga2,nil,chkf)
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and PLAYER_NONE or tp
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e)
	local sg1=Duel.GetMatchingGroup(s.fusfilter2,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil,e,tp,mg1,mg2,nil,chkf)
	if #sg1>0 then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
		Duel.ConfirmCards(tp,g)
		local sg=sg1:Clone()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local mgsel=mg1:Select(tp,1,1,nil)
			local mgc=mgsel:GetFirst()
			Duel.HintSelection(mgsel)
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg2,mgc,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION+REASON_RETURN)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		end
		tc:CompleteProcedure()
	end
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_FUSION)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,nil,0,0)
		tc=g:GetNext()
	end
end
