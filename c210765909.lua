--Sayuri·永远鲜红的幼月
xpcall(function() require("expansions/script/c210765765") end,function() require("script/c210765765") end)
local m,cm=Senya.SayuriRitualPreload(210765909)
function cm.initial_effect(c)
	c:EnableReviveLimit()
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(m,0))
	e6:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_HAND)
	e6:SetCountLimit(1,m)
	e6:SetCost(Senya.SelfDiscardCost)
	e6:SetTarget(cm.target)
	e6:SetOperation(cm.activate)
	c:RegisterEffect(e6)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(cm.dtg)
	e2:SetValue(aux.TRUE)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+0x1c0)
	e2:SetCountLimit(1)
	e2:SetCost(cm.thcost)
	e2:SetOperation(cm.atkop)
	c:RegisterEffect(e2)
end
cm.mat_filter=Senya.SayuriDefaultMaterialFilterLevel8
function cm.filter1(c,att)
	if att and not c:IsAttribute(att) then return false end
	return Senya.check_set_sayuri(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function cm.filter2(c,mg)
	return c:IsFaceup() and c:IsAbleToGrave() and mg:IsExists(Card.IsAttribute,1,nil,c:GetAttribute())
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=Duel.GetMatchingGroup(cm.filter1,tp,LOCATION_DECK,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c:IsAttribute(e:GetLabel()) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter2,tp,0,LOCATION_MZONE,1,nil,mg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,cm.filter2,tp,0,LOCATION_MZONE,1,1,nil,mg)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,0,0)
	e:SetLabel(g:GetFirst():GetAttribute())
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local mg=Duel.GetMatchingGroup(cm.filter1,tp,LOCATION_DECK,0,nil,tc:GetAttribute())
	if tc:IsRelateToEffect(e) and tc:IsAbleToGrave() and not tc:IsImmuneToEffect(e) and #mg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=mg:Select(tp,1,1,nil)
		g:AddCard(tc)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function cm.dtg(e,c)
	return c:IsAttackBelow(500) and c:IsFaceup() and not c:IsImmuneToEffect(e)
end
function cm.thcfilter(c)
	return Senya.check_set_sayuri(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost() and c:IsFaceup()
end
function cm.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thcfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cm.thcfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	local s=(g:GetFirst():GetOriginalType() & TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)==0 and 2 or 0
	Duel.SendtoDeck(g,nil,s,REASON_COST)
end
function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-1500)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end