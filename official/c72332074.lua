--超量必殺アルファンボール
--Super Quantal Alphan Spike
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle as many cards your opponent controls as possible into the Deck, then your opponent Special Summons 1 monster from their Extra Deck, ignoring its Summoning conditions
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_SUPER_QUANTUM),tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)>=3 end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Activate 1 "Super Quantal Mech Ship Magnacarrier" from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.actcost)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SUPER_QUANTUM}
s.listed_names={58753372,10424147} --"Super Quantal Fairy Alphan", "Super Quantal Mech Ship Magnacarrier"
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 and Duel.IsPlayerCanSpecialSummon(1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.spfilter(c,e,opp)
	return c:IsMonster() and Duel.GetLocationCountFromEx(opp,opp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,opp,true,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.GetOperatedGroup():IsExists(Card.IsLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA) then
		Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(opp,s.spfilter,opp,LOCATION_EXTRA,0,1,1,nil,e,opp)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(sg,0,opp,opp,true,false,POS_FACEUP)
		end
	end
end
function s.actcostfilter(c)
	return c:IsCode(58753372) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.actcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.actcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,c)
	Duel.Remove(g+c,POS_FACEUP,REASON_COST)
end
function s.actfilter(c,tp)
	return c:IsCode(10424147) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if sc then
		Duel.ActivateFieldSpell(sc,e,tp,eg,ep,ev,re,r,rp)
	end
end
