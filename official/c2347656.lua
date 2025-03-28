--白銀の城のラビュリンス
--Lovely Labrynth of the Silver Castle
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Prevent activations in response to your Normal Traps
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.chainop)
	c:RegisterEffect(e1)
	--Set 1 Trap from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.fgtg)
	e2:SetOperation(s.fgop)
	c:RegisterEffect(e2)
	--Destroy 1 card in your opponent's hand or field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rp==tp and rc:IsNormalTrap() and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return rp==tp or not e:IsMonsterEffect()
end
function s.filter(c)
	return c:IsNormalTrap() and c:IsSSetable()
end
function s.fgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.fgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)>0 then
		--Cannot be activated unless you control a Fiend monster
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetCondition(s.triggercon)
		tc:RegisterEffect(e1)
	end
end
function s.triggercon(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_FIEND),tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re and re:IsTrapEffect() and re:GetHandler():GetOriginalType()==TYPE_TRAP
		and eg:IsExists(s.cfilter,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD|LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD|LOCATION_HAND)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
	local b1=#g1>0
	local b2=#g2>0
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	local sg=Group.CreateGroup()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		sg=g1:Select(tp,1,1,nil)
		Duel.HintSelection(sg,true)
	elseif op==2 then
		sg=g2:RandomSelect(tp,1)
	end
	if #sg>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end