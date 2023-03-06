--リンク・パーティー
--Link Party
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER+CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsAttackAbove(2500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(3000)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLinkMonster),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=lg:GetClassCount(Card.GetOriginalAttribute)
	if chk==0 then
		return ct==3 or ct==4
			or (ct==1 and lg:FilterCount(Card.IsControler,nil,tp)>0)
			or (ct==2 and lg:FilterCount(Card.IsControler,nil,1-tp)>0)
			or (ct==5 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp))
			or (ct==6 and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil))
	end
	if ct==3 then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1500)
	elseif ct==4 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
	elseif ct==5 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif ct==6 then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLinkMonster),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #lg==0 then return end
	local ct=lg:GetClassCount(Card.GetOriginalAttribute)
	if ct==1 then
		local g1=lg:Filter(Card.IsControler,nil,tp)
		if #g1==0 then return end
		for tc1 in g1:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc1:RegisterEffect(e1)
		end
	elseif ct==2 then
		local g2=lg:Filter(Card.IsControler,nil,1-tp)
		if #g2==0 then return end
		for tc2 in g2:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc2:RegisterEffect(e1)
		end
	elseif ct==3 then
		Duel.Recover(tp,1500,REASON_EFFECT)
	elseif ct==4 then
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	elseif ct==5 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
		local g3=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if #g3==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g3:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	elseif ct==6 then
		local g4=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
		if #g4==0 then return end
		Duel.Destroy(g4,REASON_EFFECT)
	end
end