--月女神の鏃
--Ultimate Slayer
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Return to the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.tdcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
function s.tdcostfilter(c,e,tp)
	return c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_MZONE,1,nil,e,c:GetType()&(TYPE_EXTRA|TYPE_PENDULUM))
end
function s.tdfilter(c,e,extype)
	return c:IsFaceup() and c:IsType(extype) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdcostfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tdcostfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetType()&(TYPE_EXTRA|TYPE_PENDULUM))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local extype=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and s.tdfilter(chkc,e,extype) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_MZONE,1,1,nil,e,extype)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp or not e:IsMonsterEffect() end)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end