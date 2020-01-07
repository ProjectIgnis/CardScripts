--Junk Dealer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return #eg==1 and tc:IsControler(1-tp) and tc:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.mgfilter(c,e,tp,fusc)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE) and c:GetReason()&0x40008==0x40008 
		and c:GetReasonCard()==fusc and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	local mg=tc:GetMaterial()
	if not mg then return false end
	local mgg=mg:Filter(s.mgfilter,nil,e,tp,tc)
	if chk==0 then return #mgg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>#mgg-1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mgg,#mgg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local mg=tc:GetMaterial():Filter(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,tc)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=#mg-1 then return end
	Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
end
