--方界波動
--Cubic Wave
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--add counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.countertg)
	e2:SetOperation(s.counterop)
	c:RegisterEffect(e2)
end
s.listed_series={0xe3}
s.counter_place_list={0x1038}
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if hc:IsFaceup() and hc:IsRelateToEffect(e) then
			Duel.BreakEffect()
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK_FINAL)
			e2:SetValue(hc:GetAttack()/2)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			hc:RegisterEffect(e2)
		end
	end
end
function s.cfilter(c)
	return c:IsSetCard(0xe3) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.countertg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and #tg>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,#tg,nil)
	local ct=#g
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=tg:Select(tp,ct,ct,nil)
	Duel.SetTargetCard(sg)
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:AddCounter(0x1038,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetCondition(s.disable)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE)
		tc:RegisterEffect(e2)
	end
end
function s.disable(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
