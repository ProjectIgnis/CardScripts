--エターナル・フェイバリット
--Eternal Favorite
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_YUBEL}
s.listed_series={SET_YUBEL}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_YUBEL) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_YUBEL)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil),s.fcheck
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local fustg=Fusion.SummonEffTG(nil,Fusion.OnFieldMat,s.fextra)
	--Special Summon 1 of your "Yubel" monsters that is banished or in your GY
	local b1=not Duel.HasFlagEffect(tp,id) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
	--Fusion Summon using monsters from either field as material, including a "Yubel" monster
	local b2=not Duel.HasFlagEffect(tp,id+1) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_YUBEL),tp,LOCATION_ONFIELD,0,1,nil)
		and c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED)
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		and fustg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
		Duel.SendtoGrave(c,REASON_COST)
		fustg(e,tp,eg,ep,ev,re,r,rp,1)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Special Summon 1 of your "Yubel" monsters that is banished or in your GY
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
			--Neither player can activate cards or effects when that monster is Special Summoned
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_END)
			e1:SetLabelObject(sc)
			e1:SetOperation(s.limop)
			Duel.RegisterEffect(e1,tp)
		end
		Duel.SpecialSummonComplete()
	elseif op==2 then
		--Fusion Summon using monsters from either field as material, including a "Yubel" monster
		Fusion.SummonEffOP(nil,Fusion.OnFieldMat,s.fextra)(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	local ex,sg=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if ex and #sg==1 and sg:GetFirst()==sc and sc:HasFlagEffect(id) then
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	e:Reset()
end