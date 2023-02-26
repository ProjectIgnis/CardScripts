--Believe in your Bro
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabelObject(e)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={0x3008,0x16}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=g:FilterCount(Card.IsSetCard,nil,0x3008)>0 and Duel.IsExistingMatchingCard(s.dtpfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetFlagEffect(tp,id)==0
	local b2=g:FilterCount(s.rfilter,nil)>0 and Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and ft>0 and Duel.GetFlagEffect(tp,id+100)==0
	local b3=g:FilterCount(s.rhfilter,nil,tp)>0 and s.fusTarget(e,tp,eg,ep,ev,re,r,rp,0) and Duel.GetFlagEffect(tp,id+200)==0
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	--Apply effect
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=g:FilterCount(Card.IsSetCard,nil,0x3008)>0 and Duel.IsExistingMatchingCard(s.dtpfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetFlagEffect(tp,id)==0
	local b2=g:FilterCount(s.rfilter,nil)>0 and ft>0 and Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetFlagEffect(tp,id+100)==0
	local b3=g:FilterCount(s.rhfilter,nil,tp)>0 and s.fusTarget(e,tp,eg,ep,ev,re,r,rp,0) and Duel.GetFlagEffect(tp,id+200)==0
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)})
	--Discard 1 Trap to add 1 Machine "roid" and potentially destroy 1 opponent's monster
	if op==1 then
		--OPD register
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		--Discard 1 Trap to add "roid" to hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local dtc=Duel.SelectMatchingCard(tp,s.dtpfilter,tp,LOCATION_HAND,0,1,1,nil)
		if Duel.SendtoGrave(dtc,REASON_COST+REASON_DISCARD)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local thc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
			local atk=thc:GetAttack()
			if Duel.SendtoHand(thc,tp,REASON_EFFECT)>0 then
				Duel.ConfirmCards(1-tp,thc)
				if Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
					local dc=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk):GetFirst()
					Duel.HintSelection(dc)
					Duel.Destroy(dc,REASON_EFFECT)
				end
			end
		end
	--Discard 1 Spell to Special Summon 1 Level 6 or lower Machine "roid" or "Elemental HERO" from Deck
	elseif op==2 then
		--OPD Register
		Duel.RegisterFlagEffect(tp,id+100,0,0,0)
		--Discard 1 Spell to Special Summon "roid" or "Elemental HERO" monster
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local dsc=Duel.SelectMatchingCard(tp,s.dspfilter,tp,LOCATION_HAND,0,1,1,nil)
		if Duel.SendtoGrave(dsc,REASON_COST+REASON_DISCARD)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
			if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE_EFFECT)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				sc:RegisterEffect(e1)
			end
		end
	--Discard 1 card to Fusion Summon using only "roid" or "HERO" monsters you control
	elseif op==3 then
		local g2=s.fusTarget(e,tp,eg,ep,ev,re,r,rp,0)
		--OPD Register
		Duel.RegisterFlagEffect(tp,id+200,0,0,0)
		--Fusion Procedure
		s.fusTarget(e,tp,eg,ep,ev,re,r,rp,1)
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.matfilter,nil,e)
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
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
--Discard/Search/Destroy Functions
function s.dtpfilter(c)
	return c:IsTrap() and c:IsAbleToGraveAsCost()
end
function s.thfilter(c)
	return c:IsLevelBelow(6) and c:IsSetCard(0x16) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand() 
end
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsMonster() and c:IsAttackBelow(atk)
end
--Discard/Special Summon functions
function s.rfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsSetCard(0x16) and c:IsMonster()
end
function s.dspfilter(c)
	return c:IsSpell() and c:IsAbleToGraveAsCost()
end
function s.spfilter(c,e,tp)
	return ((s.rfilter(c) and c:IsLevelBelow(6)) or c:IsSetCard(0x3008)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
--Fusion Summon functions
function s.rhfilter(c,tp)
	return c:IsSetCard(0x3008) and c:IsMonster() and c:IsFaceup() and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.rfilter),tp,LOCATION_MZONE,0,1,nil)
end
function s.fusfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.fusTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.matfilter,nil,e)
	local res=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,mg2,mf,chkf)
		end
	end
	if chk==0 then return res and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.matfilter(c,e)
	return not c:IsImmuneToEffect(e) and (c:IsSetCard(0x3008) or c:IsSetCard(0x16)) and c:IsOnField()
end