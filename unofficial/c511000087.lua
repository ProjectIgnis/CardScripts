--召喚時計
--Summoning Clock
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.turncount)
	c:RegisterEffect(e3)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp~=tp
end
function s.turncount(e,tp,eg,ep,ev,re,r,rp)
	if tp~=Duel.GetTurnPlayer() then return end
	e:GetHandler():AddCounter(0x1105,1)
end
function s.spfilter(c,e,tp)
	return c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x1105)
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,nil) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,ct,nil,e,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,nil)
	Duel.Release(g+c,REASON_COST)
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1,ct)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffectLabel(id)
	if not ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,ct,ct,nil,e,tp)
	if #g<=0 or #g>Duel.GetLocationCount(tp,LOCATION_MZONE) then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
