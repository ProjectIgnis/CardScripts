-- 悪醒師ナイトメルト
-- Evil-Awakening Master Nightmelt
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp,cc,sumloc,race,att,lv,atk,def,code)
	if c:IsLocation(LOCATION_EXTRA) and (sumloc~=LOCATION_EXTRA or Duel.GetLocationCountFromEx(tp,tp,cc,c)<1) then return false end
	return not c:IsOriginalCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsOriginalRace(race) and c:IsOriginalAttribute(att)
		and c:GetOriginalLevel()==lv and c:GetTextAttack()==atk and c:GetTextDefense()==def
end
function s.getprops(c)
	return c:GetSummonLocation(),c:GetOriginalRace(),c:GetOriginalAttribute(),c:GetOriginalLevel(),c:GetTextAttack(),c:GetTextDefense(),c:GetOriginalCode()
end
function s.spcostfilter(c,e,tp)
	local loc=Duel.GetMZoneCount(tp,c)>0 and LOCATION_DECK+LOCATION_EXTRA or LOCATION_EXTRA
	return Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp,c,s.getprops(c))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.spcostfilter,1,false,nil,nil,e,tp) end
	local rc=Duel.SelectReleaseGroupCost(tp,s.spcostfilter,1,1,false,nil,nil,e,tp):GetFirst()
	e:SetLabelObject(rc)
	Duel.Release(rc,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local rc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil,s.getprops(rc))
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end