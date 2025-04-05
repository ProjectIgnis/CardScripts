--Ｌｉｖｅ☆Ｔｗｉｎ チャンネル
--Live☆Twin Channel
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Negate an attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.negcost)
	e2:SetOperation(function() Duel.NegateAttack() end)
	c:RegisterEffect(e2)
	--Return 1 "Ki-sikil" or "Lil-la" monster from your GY to your Deck or hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_KI_SIKIL,SET_LIL_LA}
function s.costfilter(c,tp)
	return (c:IsSetCard(SET_KI_SIKIL) or c:IsSetCard(SET_LIL_LA)) and c:IsMonster()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,nil,nil,{SET_KI_SIKIL,SET_LIL_LA}) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,nil,nil,{SET_KI_SIKIL,SET_LIL_LA})
	Duel.Release(g,REASON_COST)
end
function s.tgfilter(c,mon_check)
	return c:IsSetCard({SET_KI_SIKIL,SET_LIL_LA}) and c:IsMonster() and (c:IsAbleToDeck() or (mon_check and c:IsAbleToHand()))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mon_check=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc,mon_check) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil,mon_check) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,mon_check)
	if not mon_check then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and tc:IsAbleToHand()
		and (not tc:IsAbleToDeck() or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end