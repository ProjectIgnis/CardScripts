--十二獣クックル
--Zoodiac Kataroost
local s,id=GetID()
function s.initial_effect(c)
	--Send to the deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.tdcon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--Grant effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.discon)
	e2:SetCost(Cost.Detach(1,1,nil))
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ZOODIAC}
s.listed_names={id}
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.tdfilter(c)
	return c:IsSetCard(SET_ZOODIAC) and not c:IsCode(id) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOriginalRace()==RACE_BEASTWARRIOR
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		and re:IsMonsterEffect() and Duel.IsChainNegatable(ev)
		and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS) and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end