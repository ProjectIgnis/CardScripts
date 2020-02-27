--Gagaga Head (Manga)
--fixed by MLD
--NOTE: Change Draw effect to trigger once implementable
local s,id=GetID()
function s.initial_effect(c)
	--summon with no tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	--summon success
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--effect gain (changed)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.efcon)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
	--xyz summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
end
s.listed_series={0x54,0x48}
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc==0 and c:GetLevel()>4 and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,2,nil,TYPE_MONSTER)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x54) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=nil
	if #tg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local n = e:GetHandler():GetReasonCard():GetOverlayGroup():FilterCount(Card.IsSetCard,nil,0x54)
	Duel.Draw(tp,n,REASON_EFFECT)
end
function s.xyzfilter(c,m,cc)
	if not c:IsType(TYPE_XYZ) or not c:IsSetCard(0x48) or not c.xyz_filter then return false end
	local f,lv,ct,alterf,desc,maxct,op,mustbemat,exchk=table.unpack(c.xyz_parameters)
	if not maxct then maxct=ct end
	local e1=Effect.CreateEffect(cc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1073)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(Xyz.Condition(f,lv,ct,maxct,mustbemat,exchk))
	e1:SetTarget(Xyz.Target(f,lv,ct,maxct,mustbemat,exchk))
	e1:SetOperation(Xyz.Operation(f,lv,ct,maxct,mustbemat,exchk))
	e1:SetValue(SUMMON_TYPE_XYZ)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	local res=c:IsXyzSummonable(nil,m,#m,#m)
	e1:Reset()
	return res
end
function s.gafilter(c)
	return c:IsSetCard(0x54) and c:IsFaceup()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local m=Duel.GetMatchingGroup(s.gafilter,tp,LOCATION_MZONE,0,nil)
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_GRAVE,0,1,nil,m,e:GetHandler()) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local m=Duel.GetMatchingGroup(s.gafilter,tp,LOCATION_MZONE,0,nil)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_GRAVE,0,nil,m,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		local f,lv,ct,alterf,desc,maxct,op,mustbemat,exchk=table.unpack(tc.xyz_parameters)
		if not maxct then maxct=ct end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetDescription(1073)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCondition(Xyz.Condition(f,lv,ct,maxct,mustbemat,exchk))
		e1:SetTarget(Xyz.Target(f,lv,ct,maxct,mustbemat,exchk))
		e1:SetOperation(Xyz.Operation(f,lv,ct,maxct,mustbemat,exchk))
		e1:SetValue(SUMMON_TYPE_XYZ)
		e1:SetReset(RESET_CHAIN)
		tc:RegisterEffect(e1)
		Duel.XyzSummon(tp,tc,nil,m)
	end
end
