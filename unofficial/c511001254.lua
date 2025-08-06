--ＥＭアフター・エンドロール
--Performapal Curtain Call
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 monster you control; apply the following effects
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(function() return not (Duel.IsPhase(PHASE_DAMAGE) or Duel.IsDamageCalculated()) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Global register for "Performapal" monsters destroyed this turn
	aux.GlobalCheck(s,function()
		s[0]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=0
		end)
	end)
end
function s.regfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_PERFORMAPAL) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local regct=eg:FilterCount(s.regfilter,nil)
	if regct==0 then return end
	s[0]=s[0]+regct
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Gains 600 ATK for each "Performapal" monster destroyed this turn
		tc:UpdateAttack(s[0]*600,RESETS_STANDARD_PHASE_END)
		--Cannot be destroyed by battle or card effects
		local e2a=Effect.CreateEffect(c)
		e2a:SetType(EFFECT_TYPE_SINGLE)
		e2a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2a:SetValue(1)
		e2a:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2a)
		local e2b=e2a:Clone()
		e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2b)
		--If this card attacks, negate the effects of all cards your opponent controls
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_ATTACK_ANNOUNCE)
		e3:SetOperation(s.atkop)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e3)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	local c=e:GetHandler()
	for tc in g:Iter() do
		tc:NegateEffects(c)
	end
end
