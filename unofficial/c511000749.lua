--シンクロ・トランセンド (Manga)
--Synchro Transcend (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,c:GetLevel(),e,tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e,tp) and ep~=tp
end
function s.filter(c,lv,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:GetLevel()==lv+1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	local g=eg:Filter(s.cfilter,nil,e,tp)
	local rg=Group.CreateGroup()
	local tc=g:GetFirst()
	while tc do
		local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,tc:GetLevel(),e,tp)
		rg:Merge(sg)
		tc=g:GetNext()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sp=rg:Select(tp,1,1,nil)
	Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
end
