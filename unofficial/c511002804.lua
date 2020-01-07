--Flash Tune
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsType,nil,TYPE_SYNCHRO)
	return #g==1
end
function s.spfilter(c,g)
	return c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil,g)
end
function s.filter(c,tp,mc)
	return c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,Group.FromCards(c,mc))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(Card.IsType,nil,TYPE_SYNCHRO)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,tp,g:GetFirst()) end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=eg:Filter(Card.IsType,nil,TYPE_SYNCHRO):GetFirst()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,tp,tc)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local matg=g:Select(tp,1,1,nil)
		matg:AddCard(tc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,matg):GetFirst()
		Duel.SynchroSummon(tp,sc,nil,mat)
	end
end
