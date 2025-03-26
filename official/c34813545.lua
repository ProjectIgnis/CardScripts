--ナチュルの春風
--Naturia Blessing
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NATURIA}
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.syntg(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=s.fustg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		s.syntg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==3 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	Duel.SetTargetParam(op)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp,chk)
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then s.spop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then s.synop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then s.fusop(e,tp,eg,ep,ev,re,r,rp) end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NATURIA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.syncheck(tp,sg,sc)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_NATURIA)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		Synchro.CheckAdditional=s.syncheck
		local res=Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil)
		Synchro.CheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	Synchro.CheckAdditional=s.syncheck
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst())
	end
	Synchro.CheckAdditional=nil
end
function s.fuscheck(tp,sg,fc)
	return sg:IsExists(aux.FilterBoolFunction(Card.IsSetCard,SET_NATURIA,fc,SUMMON_TYPE_FUSION,tp),1,nil)
end
function s.fusextra(e,tp,mg)
	return nil,s.fuscheck
end
s.fustg=Fusion.SummonEffTG(nil,Fusion.OnFieldMat,s.fusextra)
s.fusop=Fusion.SummonEffOP(nil,Fusion.OnFieldMat,s.fusextra)