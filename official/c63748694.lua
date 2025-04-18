--赤しゃりの軍貫
--Gunkan Suship Shari Red
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Change its name to "Gunkan Suship Shari"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
	e1:SetValue(CARD_SUSHIP_SHARI)
	c:RegisterEffect(e1)
	--Special Summon itself from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_SUSHIP_SHARI}
s.listed_series={SET_GUNKAN}
function s.cfilter(c)
	return c:IsCode(CARD_SUSHIP_SHARI) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.spfilter(c,e,tp,mc)
	return c:IsSetCard(SET_GUNKAN) and not c:IsCode(CARD_SUSHIP_SHARI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mc,c)
end
function s.xyzfilter(c,e,tp,mc1,mc2)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(mc1,mc2),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==2 and pg:IsContains(mc1) and pg:IsContains(mc2))) and c:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:ListsCode(mc2:GetCode())
		and mc1:IsCanBeXyzMaterial(c,tp) and mc2:IsCanBeXyzMaterial(c,tp) and Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(mc1,mc2),c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,c)
		if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if not sc then return end
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			--Negate its effects
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			sc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			sc:RegisterEffect(e2)
		end
		if Duel.SpecialSummonComplete()==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyzc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,sc):GetFirst()
		if not xyzc then return end
		local mg=Group.FromCards(c,sc)
		xyzc:SetMaterial(mg)
		Duel.Overlay(xyzc,mg)
		if Duel.SpecialSummon(xyzc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			xyzc:CompleteProcedure()
		end
	end
end