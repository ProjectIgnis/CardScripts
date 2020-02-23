--ダークナイト＠イグニスター (Anime)
--Dark Templar @Ignister (Anime)
--Scripted by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
   --link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),3,3,s.lcheck)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(s.indes)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(alias,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(alias,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
s.listed_series={0x135}
function s.lfilter(c,att,lc,tp)
	return c:IsAttribute(att,lc,SUMMON_TYPE_LINK,tp)
end
function s.lcheck(g,lc,tp)
	return g:IsExists(s.lfilter,1,nil,ATTRIBUTE_DARK,lc,tp)
end
function s.indes(e,c)
	return c:GetAttack()==e:GetHandler():GetAttack()
end
function s.filter(c,e,tp,zone)
	return c:IsSetCard(0x135) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp,zone) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then 
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
function s.lkfilter(c)
	return c:IsType(TYPE_LINK) and c:IsFaceup()
end
function s.cfilter2(c,sc,seq,tp)
	return seq and (c:GetLinkedZone(tp)&(1<<seq))~=0 or c:GetLinkedGroup():IsContains(sc)
end
function s.cfilter(c,lg,tp)
	if c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) then return lg:IsExists(s.cfilter2,1,nil,c)
	elseif c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp then return lg:IsExists(s.cfilter2,1,nil,c,c:GetPreviousSequence(),tp) end
	return false
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_MZONE,0,nil)
	return eg:IsExists(s.cfilter,1,nil,lg,tp)
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg
end
function s.spfilter(c,e,tp,zone)
	return c:IsLevelBelow(4) and c:IsSetCard(0x135) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.ltgfilter(c,e,tp)
	return c:IsLinkMonster() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLinkedZone(tp))
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ltgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.ltgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.ltgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local zone=tc:GetLinkedZone(tp)
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,zone)
		if #sg==0 then return end
		local ct=math.min(sg:GetClassCount(Card.GetCode),Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone))
		local rg=aux.SelectUnselectGroup(sg,e,tp,ct,ct,s.spcheck,1,tp,HINTMSG_SPSUMMON)
		if #rg>0 then
			local c=e:GetHandler()
			for sc in aux.Next(rg) do
				if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP,zone)~=0 then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e1)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e2)
				end
			end
			Duel.SpecialSummonComplete()
		end
	end
end
