--装甲魔導士パズー
--Armor Wizard Pazoo
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand or GY: You can target 1 face-up monster you control; equip this card to it as an Equip Spell with the following effects. You can only use this effect of "Armor Wizard Pazoo" once per turn
	--● The equipped monster gains 2100 ATK/DEF while your LP are 4000 or less
	--● When a card or effect activated by your opponent resolves, if you control a card with an effect that requires a die roll, you can negate the activated effect, then banish this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then
		Duel.SendtoGrave(c,REASON_RULE,PLAYER_NONE,PLAYER_NONE)
	elseif Duel.Equip(tp,c,tc) then
		--Equip limit
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetValue(function(e,c) return c==tc end)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e0)
		--● The equipped monster gains 2100 ATK/DEF while your LP are 4000 or less
		local e1a=Effect.CreateEffect(c)
		e1a:SetType(EFFECT_TYPE_EQUIP)
		e1a:SetCode(EFFECT_UPDATE_ATTACK)
		e1a:SetCondition(function(e)
			return Duel.GetLP(e:GetHandlerPlayer())<=4000
		end)
		e1a:SetValue(2100)
		e1a:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1a)
		local e1b=e1a:Clone()
		e1b:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e1b)
		--● When a card or effect activated by your opponent resolves, if you control a card with an effect that requires a die roll, you can negate the activated effect, then banish this card
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCondition(s.discon)
		e2:SetOperation(s.disop)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
function s.dicefilter(c)
	return c.roll_dice and c:IsFaceup()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsExistingMatchingCard(s.dicefilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsChainDisablable(ev)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAbleToRemove() and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then
		Duel.Hint(HINT_CARD,0,id)
		if Duel.NegateEffect(ev) then
			Duel.BreakEffect()
			Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
		end
	end
end