--魔轟神レヴェルゼブル
--Fabledswarm Leverzebul
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Tribute any number of "Fabled" monsters and take control of that many face-up monsters your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--Return this card to the Extra Deck and add 1 other "Fabled" card from your GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FABLED}
function s.rlfilter(c,tp,chk)
	return c:IsReleasableByEffect() and c:IsSetCard(SET_FABLED)
		and (chk==1 or Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rlfilter,tp,LOCATION_MZONE,0,1,nil,tp,chk)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAbleToChangeControler),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function s.rlrescon(sg,e,tp)
	return Duel.GetMZoneCount(tp,sg,tp,LOCATION_REASON_CONTROL)>=#sg
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToChangeControler),tp,0,LOCATION_MZONE,nil)
	if #cg==0 then return end
	local rg=Duel.GetMatchingGroup(s.rlfilter,tp,LOCATION_MZONE,0,nil,tp,1)
	if #rg==0 then return end
	local g=aux.SelectUnselectGroup(rg,e,tp,1,#cg,s.rlrescon,1,tp,HINTMSG_RELEASE)
	if #g==0 or Duel.Release(g,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup()
	local ct=#og
	if ct==0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local sg=(cg-og):Select(tp,ct,ct,nil)
	if #sg==0 then return end
	Duel.HintSelection(sg)
	if Duel.GetControl(sg,tp)>0 then
		Duel.GetOperatedGroup():ForEach(Card.NegateEffects,c)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_FABLED) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc~=c end
	if chk==0 then return c:IsAbleToExtra() and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_EXTRA) and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end