--Ｕ．Ａ．リベロスパイカー
--U.A. Libero Spiker
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--You can Special Summon this card (from your hand) by returning 1 "U.A." monster you control to the hand, except "U.A. Libero Spiker"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--During your opponent's Main Phase (Quick Effect): You can shuffle 1 Level 5 or higher "U.A." monster from your hand into the Deck, and if you do, Special Summon 1 "U.A." monster from your Deck with a different name, then return this card to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase() end)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_UA}
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_UA) and not c:IsCode(id) and c:IsAbleToHandAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RTOHAND,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoHand(g,nil,REASON_COST)
	g:DeleteGroup()
end
function s.tdfilter(c,e,tp)
	return c:IsSetCard(SET_UA) and c:IsLevelAbove(5) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter2(c,e,tp,code)
	return c:IsSetCard(SET_UA) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_ONFIELD)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	Duel.ConfirmCards(1-tp,tc)
	if Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
		local c=e:GetHandler()
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end