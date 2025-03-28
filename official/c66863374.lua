--スレイブパンサー
--Test Panther
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon procedure: 2 monsters, including a "Gladiator Beast" monster
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Add 1 "Gladiator Beast" card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Return 1 "Gladiator Beast" monster to deck, special summon 1 with a different name from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GLADIATOR_BEAST}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_GLADIATOR_BEAST,lc,sumtype,tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
end
function s.thfilter(c)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tgfilter(c,e,tp,ft)
	return c:IsFaceup() and c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsAbleToDeck() and (ft>-1 or c:GetSequence()<5)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalCodeRule())
end
function s.spfilter(c,e,tp,code)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and not c:IsOriginalCodeRule(code) and c:IsCanBeSpecialSummoned(e,130,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp,ft) end
	if chk==0 then return ft>-2 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local rc=Duel.GetFirstTarget()
	if not rc or not rc:IsFaceup() or not rc:IsRelateToEffect(e) then return end
	Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if not rc:IsLocation(LOCATION_DECK|LOCATION_EXTRA) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,rc:GetOriginalCodeRule()):GetFirst()
	if tc and Duel.SpecialSummon(tc,130,tp,tp,false,false,POS_FACEUP)>0 then
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT|RESETS_STANDARD_DISABLE,0,0)
	end
end