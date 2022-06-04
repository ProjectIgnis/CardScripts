--ＥＮシャッフル
--EN Shuffle
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Elemental HERO" or "Neo-Spacian" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Shuffle cards then draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_NEOS}
s.listed_series={0x3008,0x1f}
function s.tdfilter(c,e,tp)
	return (c:IsSetCard(0x3008) or c:IsSetCard(0x1f)) and c:IsFaceup()
		and c:IsAbleToDeck() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,code)
	return (c:IsSetCard(0x3008) or c:IsSetCard(0x1f)) and not c:IsCode(code)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	local code=tc:GetCode()
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tdfilter2(c)
	return (c:IsSetCard(0x3008) or c:IsSetCard(0x1f)) and c:IsMonster() and c:IsAbleToDeck()
end
function s.resfilter(c,sg)
	return c:IsSetCard(0x3008) and sg:IsExists(Card.IsSetCard,1,c,0x1f)
end
function s.rescon(sg,e,tp)
	return (#sg==1 and sg:IsExists(Card.IsCode,1,nil,CARD_NEOS)) or sg:IsExists(s.resfilter,1,nil,sg)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter2,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter2,tp,LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_DISCARD,s.rescon)
	if #sg==0 then return end
	Duel.HintSelection(sg,true)
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==#sg then
		local og=Duel.GetOperatedGroup()
		if og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)~=#sg then return end
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end