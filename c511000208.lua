--封印の黄金櫃
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	if Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)>0 then
		local code=tc:GetCode()
		--Negate
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_CHAINING)
		e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		e1:SetRange(LOCATION_SZONE)
		e1:SetLabel(code)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.negcon)
		e1:SetCost(s.negcost)
		e1:SetTarget(s.negtg)
		e1:SetOperation(s.negop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		--instant
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(93016201,0))
		e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCode(EVENT_SPSUMMON)
		e2:SetLabel(code)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.negcon2)
		e2:SetCost(s.negcost)
		e2:SetTarget(s.negtg2)
		e2:SetOperation(s.negop2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EVENT_SUMMON)
		c:RegisterEffect(e3)
		local e4=e2:Clone()
		e4:SetCode(EVENT_FLIP_SUMMON)
		c:RegisterEffect(e4)
		tc:CreateEffectRelation(e1)
		tc:CreateEffectRelation(e2)
		tc:CreateEffectRelation(e3)
		tc:CreateEffectRelation(e4)
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:GetHandler():IsCode(e:GetLabel()) 
		and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc and tc:IsRelateToEffect(e) and tc:IsFacedown() end
	Duel.ConfirmCards(1-tp,tc)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0 and eg:IsExists(s.filter,1,nil,e:GetLabel())
end
function s.negtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.filter,nil,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.negop2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.filter,nil,e:GetLabel())
	Duel.NegateSummon(g)
	Duel.Destroy(g,REASON_EFFECT)
end
