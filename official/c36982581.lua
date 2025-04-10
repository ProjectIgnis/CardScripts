--リチュアの氷魔鏡
--Gishki Nekromirror
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Return to the top and bottom of the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GISHKI}
function s.spfilter(c,e,tp)
	return c:IsRitualMonster() and c:IsSetCard(SET_GISHKI) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,e,c)
end
function s.cfilter(c,e,sc)
	return c:IsFaceup() and c:IsCanBeRitualMaterial(sc) and not c:IsImmuneToEffect(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rparams={filter=aux.FilterBoolFunction(Card.IsSetCard,SET_GISHKI),lvtype=RITPROC_EQUAL,stage2=s.stage2}
	local rittg=Ritual.Target(rparams)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp))
		or rittg(e,tp,eg,ep,ev,re,r,rp,chk) end
	rittg(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rparams={filter=aux.FilterBoolFunction(Card.IsSetCard,SET_GISHKI),lvtype=RITPROC_EQUAL,stage2=s.stage2}
	local rittg,ritop=Ritual.Target(rparams),Ritual.Operation(rparams)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=rittg(e,tp,eg,ep,ev,re,r,rp,0)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	if op==1 then
		--Tribute 1 opponent's face-up monster
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		if not sc then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local rg=Duel.SelectMatchingCard(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil,e,sc)
		if #rg==0 then return end
		sc:SetMaterial(rg)
		Duel.ReleaseRitualMaterial(rg)
		Duel.BreakEffect()
		if Duel.SpecialSummon(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)==0 then return end
		sc:CompleteProcedure()
		Duel.SetLP(tp,Duel.GetLP(tp)-sc:GetBaseAttack())
	elseif op==2 then
		--Tribute monsters from your hand or field
		ritop(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,sc)
	Duel.SetLP(tp,Duel.GetLP(tp)-sc:GetBaseAttack())
end
function s.tdfilter(c)
	return c:IsSetCard(SET_GISHKI) and c:IsMonster() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g+c,2,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK|LOCATION_EXTRA)) then return end
	if tc:IsLocation(LOCATION_DECK) then Duel.ConfirmDecktop(tp,1) end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end