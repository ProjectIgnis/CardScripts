--クルセイド・パラディオン
--Crusadia Vanguard
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--cannot select, except link thing
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(s.catcondition)
	e2:SetValue(s.catlimit)
	c:RegisterEffect(e2)
end
s.listed_series={0x116,0xfe}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if s.spcost(e,tp,eg,ep,ev,re,r,rp,0) and s.sptarget(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		s.spcost(e,tp,eg,ep,ev,re,r,rp,1)
		s.sptarget(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetOperation(s.spoperation)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x116) or c:IsSetCard(0xfe))
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,tc)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x116) or c:IsSetCard(0xfe)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsOriginalCode(tc:GetOriginalCode())
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			and Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,e,tp)
	end
	e:SetLabel(0)
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,e,tp)
	Duel.Release(g,REASON_COST)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,tc)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.catfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x116) and c:IsLinkMonster()
end
function s.catcondition(e)
	return Duel.IsExistingMatchingCard(s.catfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.catlimit(e,c)
	return not c:IsLinkMonster()
end
