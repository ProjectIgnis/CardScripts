--聖天樹の幼精
--Sunavalon Dryas
--Fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--cannot link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetCondition(s.matcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0x575,0x574}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsType(TYPE_NORMAL,lc,sumtype,tp) and c:IsRace(RACE_PLANT,lc,sumtype,tp)
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetTurnID()==Duel.GetTurnCount()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r&REASON_BATTLE+REASON_EFFECT~=0
end
function s.filter(c,e,tp,zone)
	return c:IsSetCard(0x575) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.lkfilter(c)
	return c:IsSetCard(0x574) and c:IsFaceup() and c:IsLinkMonster()
end
function s.zonefilter(tp)
	local lg=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_MZONE,0,nil)
	local zone=0
	lg:ForEach(function(tc)
		zone=zone|tc:GetLinkedZone()
	end)
	return zone
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=s.zonefilter(tp)
	if chk==0 then
		local zone=s.zonefilter(tp)
		return zone~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,zone)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=s.zonefilter(tp)
	if Duel.GetLocationCountFromEx(tp)<=0 and zone~=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,zone)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)>0 then
		Duel.Recover(tp,ev,REASON_EFFECT)
	end
end
