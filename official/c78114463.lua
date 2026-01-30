--神の密告
--Solemn Report
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can activate this card the turn it was Set, by revealing 1 other Set Trap you control
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetValue(function(e) e:SetLabel(1) end)
	e0:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.AND(Card.IsFacedown,Card.IsTrap),e:GetHandlerPlayer(),LOCATION_SZONE,0,1,e:GetHandler()) end)
	c:RegisterEffect(e0)
	--When a Spell/Trap Card is activated: Activate 1 of these effects;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) end)
	e1:SetCost(Cost.AND(s.revealcost,s.paylpcost))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
end
function s.revealcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFacedown,Card.IsTrap),tp,LOCATION_SZONE,0,1,1,e:GetHandler())
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.banish_activation_chk(e,tp)
	local re=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_EFFECT)
	local rc=re:GetHandler()
	return rc:IsAbleToRemove(tp) or (not rc:IsRelateToEffect(re) and Duel.IsPlayerCanRemove(tp))
end
s.paylpcost=Cost.Choice(
	{Cost.PayLP(1500),aux.Stringid(id,2),aux.TRUE},
	{Cost.PayLP(3000),aux.Stringid(id,3),s.banish_activation_chk}
)
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=e:GetLabel()
	local rc=re:GetHandler()
	local relation=rc:IsRelateToEffect(re)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if op==1 then
		e:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
		if rc:IsDestructable() and relation then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
		end
	elseif op==2 then
		e:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
		if relation then
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,tp,0)
		else
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,rc:GetPreviousLocation())
		end
	end
end
function s.banfilter(c,code,opp)
	return c:IsOriginalCodeRule(code) and c:IsAbleToRemove(opp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local rc=re:GetHandler()
	local code=rc:GetOriginalCodeRule()
	if op==1 then
		--● Pay 1500 LP; negate the activation, and if you do, destroy that card, and if you do that, for the rest of this turn, neither player can activate cards, or the effects of cards, with its same original name
		if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
			--For the rest of this turn, neither player can activate cards, or the effects of cards, with its same original name
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,4))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,1)
			e1:SetValue(function(e,re,tp) return re:GetHandler():IsOriginalCodeRule(code) end)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	elseif op==2 then
		--● Pay 3000 LP; negate the activation, and if you do, banish that card, then your opponent banishes all cards with its same original name from their hand and Deck
		if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)>0 then
			local opp=1-tp
			local g=Duel.GetMatchingGroup(s.banfilter,tp,0,LOCATION_HAND|LOCATION_DECK,nil,code,opp)
			if #g>0 then
				Duel.BreakEffect()
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT,nil,opp)
			end
		end
	end
end