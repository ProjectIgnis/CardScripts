--カオスポッド
--Morphing Jar #2
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK)
end
function s.filter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsAbleToDeck()
end
function s.filter2(c)
	return c:IsLocation(LOCATION_DECK) and c:IsMonster()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SendtoDeck(rg,nil,SEQ_DECKTOP,REASON_EFFECT)
	rg=Duel.GetOperatedGroup():Match(s.filter2,nil)
	local ct1=rg:FilterCount(Card.IsControler,nil,tp)
	local ct2=#rg-ct1
	if ct1>0 then Duel.ShuffleDeck(tp) end
	if ct2>0 then Duel.ShuffleDeck(1-tp) end
	Duel.BreakEffect()
	local g1=nil
	local g2=nil
	if ct1>0 then g1=s.sp(e,tp,ct1) end
	if ct2>0 then g2=s.sp(e,1-tp,ct2) end
	Duel.SpecialSummonComplete()
	if g1 then Duel.ShuffleSetCard(g1) end
	if g2 then Duel.ShuffleSetCard(g2) end
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.sp(e,tp,ct)
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local dt=#g
	if dt==0 then return end
	local dlist={}
	for tc in g:Iter() do
		if tc:IsMonster() then dlist[tc:GetSequence()]=tc end
	end
	local i=dt-1
	local a=0
	local last=nil
	g=Group.CreateGroup()
	while a<ct and i>=0 do
		tc=dlist[i]
		if tc then
			g:AddCard(tc)
			last=tc
			a=a+1
		end
		i=i-1
	end
	local conf=dt-last:GetSequence()
	Duel.ConfirmDecktop(tp,conf)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	g:Match(s.spfilter,nil,e,tp)
	if #g>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=g:Select(tp,ft,ft,nil)
	end
	for tc in g:Iter() do
		Duel.DisableShuffleCheck()
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	if conf-#g>0 then
		Duel.DiscardDeck(tp,conf-#g,REASON_EFFECT|REASON_EXCAVATE)
	end
	return g
end