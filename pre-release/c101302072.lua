--黙歯録
--Apocaries
--scripted by Naim
local s,id=GetID()
local COUNTER_C=0x215
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_C)
	--When this card is activated: Place C Counters on this card equal to the number of cards your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(function(e,tp) e:GetHandler():AddCounter(COUNTER_C,Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)) end)
	c:RegisterEffect(e1)
	--Apply effects to a target based on the number of C Counters removed from this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.counter_place_list={COUNTER_C}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if chk==0 then return ct>0 and Duel.IsCanAddCounter(tp,COUNTER_C,ct,c) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,COUNTER_C,ct)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_C,1,REASON_COST)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	local b1=Duel.IsCanRemoveCounter(tp,1,0,COUNTER_C,1,REASON_COST)
	local b2=Duel.IsCanRemoveCounter(tp,1,0,COUNTER_C,2,REASON_COST) and not tc:IsAttack(0)
	local b3=Duel.IsCanRemoveCounter(tp,1,0,COUNTER_C,3,REASON_COST) and tc:IsNegatableMonster()
	local b4=Duel.IsCanRemoveCounter(tp,1,0,COUNTER_C,4,REASON_COST)
	local ct=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b3,aux.Stringid(id,4)},
		{b4,aux.Stringid(id,5)})
	Duel.RemoveCounter(tp,1,1,COUNTER_C,ct,REASON_COST)
	e:SetLabel(ct)
	if (ct==1 or ct==2) then
		e:SetCategory(CATEGORY_ATKCHANGE)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,(ct==1 and -500 or -tc:GetAttack()))
	elseif ct==3 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,tp,0)
	elseif ct==4 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local ct=e:GetLabel()
	local c=e:GetHandler()
	if ct==1 and tc:IsFaceup() then
		--It loses 500 ATK
		tc:UpdateAttack(-500,nil,c)
	elseif ct==2 and tc:IsFaceup() then
		--Change its ATK to 0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	elseif ct==3 and tc:IsFaceup() then
		--Negate its effects
		tc:NegateEffects(c)
	elseif ct==4 and tc:IsMonster() then
		--Destroy it
		Duel.Destroy(tc,REASON_EFFECT)
	end
end