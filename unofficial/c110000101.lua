--オレイカルコス・トリトス
--Orichalcos Tritos
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--Negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--Gain effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetCountLimit(1)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
s.listed_names={110000100}
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_FZONE,0)
	return tc and tc:IsFaceup() and tc:IsCode(110000100)
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.cfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.NegateActivation(ev) then
		if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
			Duel.SendtoGrave(eg,REASON_EFFECT)
		end
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():CopyEffect(110000100,RESET_EVENT+RESETS_STANDARD)
end