--冥王の間
--Domain of the Dark Ruler
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If you control no monsters, you can activate this card the turn it was Set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetCondition(function(e)
		return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
	end)
	c:RegisterEffect(e0)
	--When your opponent activates a Spell/Trap Card and you have a Level 7 or higher DARK monster with 2500 DEF in your field or GY: Negate the activation, and if you do, destroy that card, then if this card was activated during your turn, you can apply this effect.
	--● Neither player can activate Spell/Trap Cards for the rest of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
function s.negconfilter(c)
	return c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsDefense(2500) and c:IsFaceup()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(s.negconfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	e:GetChainData().your_turn_chk=Duel.IsTurnPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0
		and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetChainData().your_turn_chk
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		--● Neither player can activate Spell/Trap Cards for the rest of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,1)
		e1:SetValue(function(e,re,tp)
			return re:IsHasType(EFFECT_TYPE_ACTIVATE)
		end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end