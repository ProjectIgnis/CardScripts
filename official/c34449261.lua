--融合死円舞曲
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xad}
function s.filter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0xad)
		and Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil,tp,c)
end
function s.filter2(c,tp,tc)
	local tg=Group.FromCards(c,tc)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tg)
end
function s.desfilter(c,tg)
	return not tg:IsContains(c) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,tp,g1:GetFirst())
	g1:Merge(g2)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,g1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	local dam=g1:GetSum(Card.GetAttack)
	if g:FilterCount(Card.IsControler,nil,1-tp)==0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,dam)
	elseif g:FilterCount(Card.IsControler,nil,tp)==0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	else
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local dam=tg:Filter(Card.IsFaceup,nil):GetSum(Card.GetAttack)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tg)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 and dam>0 then
		local dg=Duel.GetOperatedGroup()
		Duel.BreakEffect()
		if dg:IsExists(aux.FilterEqualFunction(Card.GetPreviousControler,tp),1,nil) then Duel.Damage(tp,dam,REASON_EFFECT,true) end
		if dg:IsExists(aux.FilterEqualFunction(Card.GetPreviousControler,1-tp),1,nil) then Duel.Damage(1-tp,dam,REASON_EFFECT,true) end
		Duel.RDComplete()
	end
end
