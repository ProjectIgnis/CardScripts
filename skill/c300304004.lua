--Ancient Fusion
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={SET_ANCIENT_GEAR}
s.listed_names={83104731}
--Fusion Summon Functions
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)==0 and s.fusTarget(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.fusfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsSetCard(SET_ANCIENT_GEAR)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.cfilter(c,e,tp)
	if not c:IsDiscardable() then return false end
	local chkf=tp
	local mg1=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,e)
	local res=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,mg1-c,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,mg2-c,mf,chkf)
		end
	end
	return res
end
function s.fusTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Opponent takes no damage
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetCode(EFFECT_CHANGE_DAMAGE)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge1:SetTargetRange(0,1)
	ge1:SetValue(0)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	local ge2=ge1:Clone()
	ge2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	ge2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge2,tp)
	--Fusion Summon "Ancient Gear" Fusion monster
	local g2=s.fusTarget(e,tp,eg,ep,ev,re,r,rp,0)
	--OPD Register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	s.fusTarget(e,tp,eg,ep,ev,re,r,rp,1)
	local chkf=tp
	local mg1=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,e)
	local sg1=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2,sg2=nil,nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if mg1:IsExists(s.aggfilter,1,nil,e) then
				local mgd=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,nil,e)
				local mat1=aux.SelectUnselectGroup(mgd,e,tp,tc.min_material_count,tc.max_material_count,s.rescon,1,tp,HINTMSG_FMATERIAL)
				tc:SetMaterial(mat1)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			end
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
	tc:CompleteProcedure()
	--Halve battle damage from that monster
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	end
end
function s.matfilter(c,e)
	return c:IsSetCard(SET_ANCIENT_GEAR) and not c:IsImmuneToEffect(e) and c:IsCanBeFusionMaterial()
end
function s.aggfilter(c,e)
	return c:IsFaceup() and c:IsCode(83104731,95735217,7171149,12652643) and c:IsOnField() and not c:IsImmuneToEffect(e) and c:IsCanBeFusionMaterial()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.aggfilter,1,nil,e)
end