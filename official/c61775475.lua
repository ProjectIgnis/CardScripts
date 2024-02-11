--Ａ・Ｏ・Ｇ リターンゼロ
--Arms of Genex Return Zero
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 DARK Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),1,1,Synchro.NonTuner(nil),1,99)
	--Negate monster effect activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Shuffle up to 6 "Genex" monsters into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	--Register Attributes used
	aux.GlobalCheck(s,function()
		s.attr_list={}
		s.attr_list[0]=0
		s.attr_list[1]=0
		aux.AddValuesReset(function()
			s.attr_list[0]=0
			s.attr_list[1]=0
		end)
	end)
end
s.listed_series={SET_GENEX}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Duel.IsChainNegatable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.negcostfilter(c,tp,att)
	return (c:GetAttribute()&att&~s.attr_list[tp])>0 and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local att=re:GetHandler():GetAttribute()
	if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp,att) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp,att)
	s.attr_list[tp]=s.attr_list[tp]|g:GetFirst():GetAttribute()
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.tdfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(SET_GENEX) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e)
	if chk==0 then return #g>0 end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,6,aux.dpcheck(Card.GetAttribute),1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_STZONE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 or Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	local ct=tg:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if ct==0 then return end
	local g=Duel.GetFieldGroup(tp,LOCATION_STZONE,LOCATION_STZONE)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=g:Select(tp,1,ct,nil)
	if #dg>0 then
		Duel.HintSelection(dg,true)
		Duel.BreakEffect()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end