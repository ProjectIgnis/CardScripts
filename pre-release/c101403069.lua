--魔獣の昂進
--Card Crawl
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--You can banish (face-down) the top 5, 10, or 15 cards of your Deck, then target 1 face-up monster on the field; apply the appropriate effect to it
	--● 5: Its ATK/DEF become 0
	--● 10: Negate its effects
	--● 15: Banish it (face-down)
	--You can only use this effect of "Card Crawl" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	--● 5: Its ATK/DEF become 0
	local top5=Duel.GetDecktopGroup(tp,5)
	local option_1=top5:IsExists(Card.IsAbleToRemoveAsCost,5,nil,POS_FACEDOWN)
		and Duel.IsExistingTarget(aux.OR(Card.HasNonZeroAttack,Card.HasNonZeroDefense),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	--● 10: Negate its effects
	local top10=Duel.GetDecktopGroup(tp,10)
	local option_2=top10:IsExists(Card.IsAbleToRemoveAsCost,10,nil,POS_FACEDOWN)
		and Duel.IsExistingTarget(Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	--● 15: Banish it (face-down)
	local top15=Duel.GetDecktopGroup(tp,15)
	local option_3=top15:IsExists(Card.IsAbleToRemoveAsCost,15,nil,POS_FACEDOWN)
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToRemove,tp,POS_FACEDOWN),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if chk==0 then return option_1 or option_2 or option_3 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,1)},
		{option_2,aux.Stringid(id,2)},
		{option_3,aux.Stringid(id,3)})
	Duel.DisableShuffleCheck()
	local cost_group=Duel.GetDecktopGroup(tp,choice*5)
	e:GetChainData().cost_count=#cost_group
	Duel.Remove(cost_group,POS_FACEDOWN,REASON_COST)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local cost_count=e:GetChainData().cost_count
		if cost_count==5 then
			--● 5: Its ATK/DEF become 0
			return chkc:HasNonZeroAttack() or chkc:HasNonZeroDefense()
		elseif cost_count==10 then
			--● 10: Negate its effects
			return chkc:IsNegatableMonster()
		elseif cost_count==15 then
			--● 15: Banish it (face-down)
			return chkc:IsAbleToRemove(tp,POS_FACEDOWN) and chkc:IsFaceup()
		end
	end
	if chk==0 then return true end
	local cost_count=e:GetChainData().cost_count
	if cost_count==5 then
		--● 5: Its ATK/DEF become 0
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local g=Duel.SelectTarget(tp,aux.OR(Card.HasNonZeroAttack,Card.HasNonZeroDefense),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,1,tp,0)
	elseif cost_count==10 then
		--● 10: Negate its effects
		e:SetCategory(CATEGORY_DISABLE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectTarget(tp,Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	elseif cost_count==15 then
		--● 15: Banish it (face-down)
		e:SetCategory(CATEGORY_REMOVE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAbleToRemove,tp,POS_FACEDOWN),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	local cost_count=e:GetChainData().cost_count
	if cost_count==5 then
		--● 5: Its ATK/DEF become 0
		if tc:IsFacedown() then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
	elseif cost_count==10 then
		--● 10: Negate its effects
		if tc:IsFacedown() then return end
		tc:NegateEffects(c)
	elseif cost_count==15 then
		--● 15: Banish it (face-down)
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end