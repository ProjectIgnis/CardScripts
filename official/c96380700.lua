--トークバック・ランサー
--Talkback Lancer
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={0x101}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_CYBERSE,lc,sumtype,tp)
end
function s.cfilter(c,e,tp,zone)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,zone)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,c,e,tp,zone) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,c,e,tp,zone)
	Duel.Release(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function s.spfilter(c,e,tp,rc)
	return c:IsSetCard(0x101) and c:IsType(TYPE_MONSTER) and not c:IsOriginalCodeRule(rc:GetOriginalCodeRule()) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and s.spfilter(chkc,e,tp,cc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,cc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end