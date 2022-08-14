-- エクスピュアリィ・ノアール
-- Expurery Noir
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 2 Level 7 monsters, or 1 Rank 2 monster with 5+ Xyz materials
	Xyz.AddProcedure(c,nil,7,2,s.ovfilter,aux.Stringid(id,0))
	-- Unaffected by opponent's activated effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>=5 end)
	e1:SetValue(function(e,te) return te:IsActivated() and e:GetOwnerPlayer()~=te:GetOwnerPlayer() end)
	c:RegisterEffect(e1)
	-- Place 1 card to the bottom of the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tdcon)
	e2:SetCost(aux.dxmcostgen(2,2,nil))
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	c:RegisterEffect(e3)
end
s.listed_series={0x289}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRank(2) and c:GetOverlayCount()>=5
end
function s.tdconfilter(c)
	return c:IsSetCard(0x289) and c:IsLevel(1)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:IsHasType(EFFECT_TYPE_QUICK_O)==e:GetHandler():GetOverlayGroup():IsExists(s.tdconfilter,1,nil)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local loc=LOCATION_ONFIELD+LOCATION_GRAVE
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(loc) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,loc,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,loc,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end