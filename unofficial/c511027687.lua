local s,id=GetID()
function s.initial_effect(c)
	--Attack Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Effect Negate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCondition(s.condition3)
	c:RegisterEffect(e3)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_NEGATEATTACK)
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and ex and tg~=nil
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) or not re:IsActiveType(TYPE_MONSTER) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsActiveType(TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local tex,ttg,ttc=Duel.GetOperationInfo(ev,CATEGORY_NEGATE)
	if not tex or ttg==nil or not (ttc+ttg:FilterCount(Card.IsControler,nil,tp)-#ttg<=0 or ttc+ttg:FilterCount(Card.IsControler,nil,1-tp)) then return false end
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev-1,CATEGORY_DESTROY)
	if ex then return true end
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev-1,CATEGORY_DESTROY)
	return ex
end
function s.condition3(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) or not re:IsActiveType(TYPE_MONSTER) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsActiveType(TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local tex,ttg,ttc=Duel.GetOperationInfo(ev,CATEGORY_DISABLE)
	if not tex or ttg==nil or not (ttc+ttg:FilterCount(Card.IsControler,nil,tp)-#ttg<=0 or ttc+ttg:FilterCount(Card.IsControler,nil,1-tp)) then return false end
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev-1,CATEGORY_DESTROY)
	if ex then return true end
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev-1,CATEGORY_DESTROY)
	return ex
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetTargetCard(eg)
end
function s.atkfilter(c)
	return c:IsFaceup()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		local tc=Duel.GetFirstTarget()
		local atk=tc:GetAttack()*2
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
			local sc=g:Select(tp,1,1,nil):GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
	end
end