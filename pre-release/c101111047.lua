-- 影の王 レイヴァーテイン
-- Laevateinn, Generaider Boss of Shadows
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	-- 2+ Level 9 monsters
	Xyz.AddProcedure(c,nil,9,2,nil,nil,99)
	-- Decrease ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- Special Summon 1 non-Fairy "Generaider" Xyz Monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_GENERAIDER}
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.SetTargetParam(c:GetOverlayCount())
	Duel.Release(c,REASON_COST)
end
function s.spfilter(c,e,tp,ec)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_GENERAIDER) and not c:IsRace(RACE_FAIRY)
		and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.ovfilter(c,xc,tp,e)
	return c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT) and not c:IsImmuneToEffect(e)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if ct==0 then return end
	local og=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.ovfilter),tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,tc,tc,tp,e)
	if #og==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=og:Select(tp,1,ct,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.BreakEffect()
		Duel.Overlay(tc,g)
	end
end