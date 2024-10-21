--スレイブベアー
--Test Bear
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card (from your hand)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.selfspcon)
	c:RegisterEffect(e1)
	--Special Summon up to 2 "Gladiator Beast" monsters from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.deckspcost)
	e2:SetTarget(s.decksptg)
	e2:SetOperation(s.deckspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GLADIATOR_BEAST}
function s.selfspconfilter(c)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsSummonLocation(LOCATION_DECK|LOCATION_EXTRA) and c:IsFaceup()
end
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.selfspconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.deckspcostfilter(c,tp,mzone_chk)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and c:IsAbleToDeckOrExtraAsCost() and (mzone_chk or Duel.GetMZoneCount(tp,c)>0)
end
function s.deckspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return c:IsReleasable() and Duel.IsExistingMatchingCard(s.deckspcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,tp,mzone_chk) end
	Duel.Release(c,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=Duel.SelectMatchingCard(tp,s.deckspcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,tp,mzone_chk):GetFirst()
	if sc:IsLocation(LOCATION_HAND) then Duel.ConfirmCards(1-tp,sc)
	else Duel.HintSelection(sc) end
	Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.deckspfilter(c,e,tp)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsCanBeSpecialSummoned(e,100,tp,false,false)
end
function s.decksptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.deckspop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	ft=math.min(ft,2)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.deckspfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,100,tp,tp,false,false,POS_FACEUP)>0 then
		for sc in g:Iter() do
			sc:RegisterFlagEffect(sc:GetOriginalCode(),RESET_EVENT|RESETS_STANDARD_DISABLE,0,1)
		end
	end
end