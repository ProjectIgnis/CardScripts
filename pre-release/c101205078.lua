--聖王の粉砕
--Dominus Purge
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Negate an effect that includes an effect to add a card(s) from the Deck to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.discond)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Can be activated from the hand if your opponent controls a card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_ONFIELD)>0 end)
	c:RegisterEffect(e2)
end
function s.discond(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainDisablable(ev) then return false end
	if re:IsHasCategory(CATEGORY_SEARCH) or re:IsHasCategory(CATEGORY_DRAW) then return true end
	local ex1,g1,gc1,dp1,loc1=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	local ex2,g2,gc2,dp2,loc2=Duel.GetPossibleOperationInfo(ev,CATEGORY_TOHAND)
	local g=Group.CreateGroup()
	if g1 then g:Merge(g1) end
	if g2 then g:Merge(g2) end
	return (((loc1 or 0)|(loc2 or 0))&LOCATION_DECK)>0 or (#g>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK))
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local act_from_hand_chk=e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) and 1 or 0
	e:SetLabel(act_from_hand_chk)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsDestructable()
		and Duel.IsExistingMatchingCard(Card.IsTrap,tp,LOCATION_GRAVE,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re)
		and Duel.IsExistingMatchingCard(Card.IsTrap,tp,LOCATION_GRAVE,0,1,nil) then
		Duel.BreakEffect()
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetLabel()==1 then
		--You cannot activate DARK/WATER/FIRE monster effects for the rest of this Duel if this card is activated from the hand
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(function(_,re) return re:IsMonsterEffect() and re:GetHandler():IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_WATER|ATTRIBUTE_FIRE) end)
		Duel.RegisterEffect(e1,tp)
	end
end