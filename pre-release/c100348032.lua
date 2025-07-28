--ジャンク・ウォリアー・エクストリーム
--Junk Warrior Extreme
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: "Junk Synchron" + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTuner(nil),1,99)
	--Special Summon as many Level 2 or lower monsters from your GY as possible
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.gysptg)
	e1:SetOperation(s.gyspop)
	c:RegisterEffect(e1)
	--Special Summon 1 "Junk" Synchro Monster from your Extra Deck (this is treated as a Synchro Summon)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.bdocon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.exsptg)
	e2:SetOperation(s.exspop)
	c:RegisterEffect(e2)
end
s.material={CARD_JUNK_SYNCHRON}
s.listed_names={CARD_JUNK_SYNCHRON}
s.listed_series={SET_JUNK}
s.material_setcode=SET_SYNCHRON
function s.tunerfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,CARD_JUNK_SYNCHRON) or c:IsHasEffect(20932152)
end
function s.gyspfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.gyspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		local g=Duel.GetMatchingGroup(s.gyspfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		ft=math.min(ft,#g)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.gyspfilter,tp,LOCATION_GRAVE,0,ft,ft,nil,e,tp)
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			local og=Duel.GetOperatedGroup()
			for sc in og:Iter() do
				--They cannot activate their effects this turn
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(3302)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				sc:RegisterEffect(e1)
			end
		end
	end
	--You can only Special Summon once for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,tp) return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)-e:GetLabel()>=1 end)
	e1:SetLabel(Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON))
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e2:SetValue(s.countval)
	Duel.RegisterEffect(e2,tp)
end
function s.countval(e,re,tp)
	local label=e:GetLabel()
	local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	if sp-label>=1 then
		return 0
	else
		return 1-sp+label
	end
end
function s.exspfilter(c,e,tp,mc)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_SYNCHRO)
	return #pg<=0 and c:IsSetCard(SET_JUNK) and c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.exsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.exspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.exspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end