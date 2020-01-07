--聖天樹の大精霊
--Sunavalon Dryanome
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PLANT),2)
	--material check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
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
	e3:SetLabelObject(e0)
	e3:SetCountLimit(3)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--move & negate
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.mvcon)
	e4:SetCost(s.mvcost)
	e4:SetOperation(s.mvop)
	c:RegisterEffect(e4)
end
s.listed_series={0x575,0x574}
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetTurnID()==Duel.GetTurnCount()
end
function s.matfilter(c)
	return c:IsOriginalSetCard(0x574)
end
function s.valcheck(e,c)
	if c:GetMaterial():IsExists(s.matfilter,1,nil,tp) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r&REASON_BATTLE+REASON_EFFECT~=0 and e:GetLabelObject():GetLabel()==1
end
function s.filter(c,e,tp,zone)
	return c:IsSetCard(0x575) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.lkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x574) and c:IsLinkMonster()
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
function s.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	local d=Duel.GetAttackTarget()
	return d and lg:IsContains(d)
end
function s.mvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttackTarget()
	if chk==0 then return Duel.GetLocationCount(at:GetControler(),LOCATION_MZONE)>0 end
	local s
	if at:IsControler(tp) then
		s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,nil)
	else
		s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,nil)
	end
	local nseq=math.log(s,2)
	Duel.MoveSequence(at,nseq)
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
