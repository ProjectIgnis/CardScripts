--Harmonic Synchro Fusion
local s,id=GetID()
function s.initial_effect(c)
	--synchro effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.fusfilter(c,e,tp,fe)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) 
		and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,c,fe)
		and Duel.GetLocationCountFromEx(tp,fe,nil,c)>1
end
function s.filter(c,e,fc,sc)
	return c:IsFaceup() and c:IsCanBeSynchroMaterial(sc) and c:IsCanBeFusionMaterial(fc) and (not e or not c:IsImmuneToEffect(e))
end
function s.synfilter(c,e,tp,fc,fe)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,fe,fc,c)
	return c:IsType(TYPE_SYNCHRO) and aux.SelectUnselectGroup(g,e,tp,fc.min_material_count,fc.max_material_count,s.rescon(fc,c,fe),0)
end
function s.rescon(fc,sc,fe)
	return	function(sg,e,tp,mg)
				local t={}
				local tc=sg:GetFirst()
				local prop=EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE
				if not fe then prop=prop|EFFECT_FLAG_IGNORE_IMMUNE end
				while tc do
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD)
					e1:SetProperty(prop)
					e1:SetRange(LOCATION_MZONE)
					e1:SetCode(EFFECT_MUST_BE_MATERIAL)
					e1:SetValue(REASON_SYNCHRO)
					e1:SetTargetRange(1,0)
					e1:SetReset(RESET_CHAIN)
					tc:RegisterEffect(e1)
					t[tc]=e1
					tc=sg:GetNext()
				end
				local res=fc:CheckFusionMaterial(sg,nil,sg) and sc:IsSynchroSummonable(nil,sg)
				tc=sg:GetFirst()
				while tc do
					t[tc]:Reset()
					tc=sg:GetNext()
				end
				return res
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
	local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and gate[tp]
	if chk==0 then return (not ect or ect>=2) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
	local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and gate[tp]
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) or (ect and ect<2) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fc=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e):GetFirst()
	if not fc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,fc,e,tp,fc,e):GetFirst()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e,fc,sc)
	local mat=aux.SelectUnselectGroup(g,e,tp,fc.min_material_count,fc.max_material_count,s.rescon(fc,sc,e),1,tp,HINTMSG_FMATERIAL,s.rescon(fc,sc,e))
	fc:SetMaterial(mat)
	sc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION+REASON_SYNCHRO)
	Duel.BreakEffect()
	Duel.SpecialSummonStep(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonStep(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonComplete()
	fc:CompleteProcedure()
	sc:CompleteProcedure()
end
