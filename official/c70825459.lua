--トラップトラック
--Trap Tracks
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 monster and Set 1 Normal Trap from the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.setfilter(c)
	return c:IsNormalTrap() and not c:IsCode(id) and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if sc and Duel.SSet(tp,sc)>0 then
			--Can be activated this turn
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--Can only activate 1 Trap for the rest of this turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetOperation(s.aclimit1)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_NEGATED)
	e3:SetOperation(s.aclimit2)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(function(e) return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0 end)
	e4:SetValue(function(_,te) return te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:IsTrapEffect() end)
	e4:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e4,tp)
end
function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsTrapEffect()) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end
function s.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsTrapEffect()) then return end
	Duel.ResetFlagEffect(tp,id)
end