--ダイナミスト・レックス
--Dinomist Rex
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--Negate an activated effect that targets another "Dinomist" card(s) you control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(s.effcon)
	e2:SetCost(s.effcost)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DINOMIST}
function s.negconfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_DINOMIST) and c:IsControler(tp) and c:IsOnField()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and not c:HasFlagEffect(id)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.negconfilter,1,c,tp) and Duel.IsChainDisablable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
	if Duel.NegateEffect(ev) then
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
	end
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c and c:IsRelateToBattle()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,nil,c,SET_DINOMIST) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,nil,c,SET_DINOMIST)
	Duel.Release(g,REASON_COST)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:GetHandler():CanChainAttack(0,true)
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD|LOCATION_HAND,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
	else
		e:SetCategory(CATEGORY_TODECK)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD|LOCATION_HAND)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		if not (c:IsFaceup() and c:IsRelateToEffect(e) and c:IsRelateToBattle()) then return end
		Duel.ChainAttack()
		--The consecutive attack must be on a monster
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE|PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
		--Inflicts piercing battle damage
		local e2=e1:Clone()
		e2:SetCode(EFFECT_PIERCE)
		c:RegisterEffect(e2)
	else
		local hg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil)
		local fg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
		local b1=#hg>0
		local b2=#fg>0
		if not (b1 or b2) then return end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,4)},
			{b2,aux.Stringid(id,5)})
		local sg=nil
		if op==1 then
			sg=hg:RandomSelect(tp,1)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			sg=fg:Select(tp,1,1,nil)
			Duel.HintSelection(sg,true)
		end
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sg:GetFirst():IsLocation(LOCATION_DECK|LOCATION_EXTRA)
			and c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.BreakEffect()
			--Gains 100 ATK
			c:UpdateAttack(100)
		end
	end
end