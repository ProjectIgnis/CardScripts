--星守の騎士団
--Constellar Tellarknights
--Scripted by Satella
local s,id=GetID()
function s.initial_effect(c)
	--Activate and (you can) Special Summon from the hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special Summon 1 "tellarknight" or "Constellar" Xyz Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TELLARKNIGHT,SET_CONSTELLAR}
function s.spfilter(c,e,tp)
	return c:IsSetCard({SET_TELLARKNIGHT,SET_CONSTELLAR}) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.xyzfilter(c,e,tp,mc)
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ) and c:IsSetCard({SET_TELLARKNIGHT,SET_CONSTELLAR})
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and not c:IsRank(mc:GetRank())
		and mc:IsCanBeXyzMaterial(c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyztgfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsSetCard({SET_TELLARKNIGHT,SET_CONSTELLAR}) and c:IsType(TYPE_XYZ)) then return false end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg==0 or (#pg==1 and pg:IsContains(c))) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyztgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xyztgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyztgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if #pg>1 or (#pg==1 and pg:GetFirst()~=tc) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc):GetFirst()
	if not sc then return end
	sc:SetMaterial(tc)
	Duel.Overlay(sc,tc)
	Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	sc:CompleteProcedure()
end