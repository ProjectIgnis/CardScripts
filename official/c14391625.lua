--ヴィサス＝サンサーラ
--Visas Samsara
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--This card's name becomes "Visas Starfrost"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(CARD_VISAS_STARFROST)
	c:RegisterEffect(e1)
	--Special Summon itself from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Can be treated as a non-tuner for a Synchro Summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_NONTUNER)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_VISAS_STARFROST}
s.listed_series={SET_VISAS}
function s.tdfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_VISAS) and c:IsMonster() and c:IsAbleToDeck() and Duel.GetMZoneCount(tp,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local loc=LOCATION_MZONE|LOCATION_REMOVED|LOCATION_GRAVE
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(loc) and s.tdfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(s.tdfilter,tp,loc,0,1,nil,tp) end
	local ct=Duel.GetMatchingGroupCount(s.tdfilter,tp,loc,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,loc,0,1,ct,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.visasfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_VISAS) and c:IsMonster()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Match(s.visasfilter,nil)
	if #g==0 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup():Match(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if #og==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		c:UpdateAttack(400*og:GetClassCount(Card.GetCode))
	end
end