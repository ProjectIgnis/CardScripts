--リオート・ミグラトリー
--Zereort Migrator
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.handspcon)
	e1:SetTarget(s.handsptg)
	e1:SetOperation(s.handspop)
	c:RegisterEffect(e1)
	--Detach 1 Xyz Material from a monster you control, then you can Special Summon 1 Level 3 or 4 WATER monster from your hand or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.xyzfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.handspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.handsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.handspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsLevel(3,4) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if not sc then return end
		Duel.BreakEffect()
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			local c=e:GetHandler()
			--Its effects are negated
			sc:NegateEffects(c)
			--If it is used for the Xyz Summon of a WATER monster this turn, it can be treated as a Level 5 monster
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_XYZ_LEVEL)
			e1:SetValue(s.xyzlv)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			sc:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.xyzlv(e,c,rc)
	local lv=e:GetHandler():GetLevel()
	if rc:IsAttribute(ATTRIBUTE_WATER) then
		return 5,lv
	else
		return lv
	end
end