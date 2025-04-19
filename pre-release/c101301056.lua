--アルトメギア・マスターワーク－継承－
--Artmegia Masterwork - Succession
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Fusion Monster from your Extra Deck
	local e1=Fusion.CreateSummonEff({handler=c,extrafil=s.fextra,stage2=s.atkop,extratg=s.atktg})
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	c:RegisterEffect(e1)
	--Shuffle into your Deck 3 "Artmegia" cards in your GY with different names
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ARTMEGIA}
function s.matcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_ARTMEGIA,fc,SUMMON_TYPE_FUSION,tp)
end
function s.fextra(e,tp,mg,sumtype)
	return nil,s.matcheck
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,500)
end
function s.atkop(e,tc,tp,mg,chk)
	if chk==1 then
		if not Duel.IsExistingMatchingCard(nil,0,LOCATION_FZONE,LOCATION_FZONE,1,nil) then return end
		Duel.BreakEffect()
		--Gains 500 ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.tdfilter(c,e)
	return c:IsSetCard(SET_ARTMEGIA) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
	if chk==0 then return #g>=3 and g:GetClassCount(Card.GetCode)>=3 end
	local tg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,3,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end