--Performpal five-Rainbow Magician (Anime)
--scripted by GameMaster(GM)
--rescripted by MLD
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--skip draw phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TURN_END)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.skipcon)
	e1:SetOperation(s.skipop)
	c:RegisterEffect(e1)
	--cannot attack/trigger/0 atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetLabel(0)
	e2:SetCondition(s.con)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetValue(0)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetLabel(1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_SET_ATTACK_FINAL)
	e6:SetValue(0)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e7)
	--negate
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(1287123,0))
	e8:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_CHAINING)
	e8:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_BOTH_SIDE)
	e8:SetRange(LOCATION_PZONE)
	e8:SetCondition(s.negcon)
	e8:SetTarget(s.negtg)
	e8:SetOperation(s.negop)
	c:RegisterEffect(e8)
	--end turn
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e9:SetCode(EVENT_MSET)
	e9:SetRange(LOCATION_PZONE)
	e9:SetTarget(s.endtg)
	e9:SetOperation(s.endop)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e10)
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e11:SetDescription(aux.Stringid(97064649,0))
	e11:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_DELAY)
	e11:SetCode(EVENT_TO_HAND)
	e11:SetRange(LOCATION_PZONE)
	e11:SetCondition(s.setcon)
	e11:SetTarget(s.settg)
	e11:SetOperation(s.setop)
	c:RegisterEffect(e11)
	s[e8]=function() return e9,e10,e11 end
	--double atk
	local e12=Effect.CreateEffect(c)
	e12:SetDescription(aux.Stringid(11439455,0))
	e12:SetCategory(CATEGORY_ATKCHANGE)
	e12:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e12:SetType(EFFECT_TYPE_IGNITION)
	e12:SetRange(LOCATION_MZONE)
	e12:SetCondition(s.atkcon)
	e12:SetTarget(s.atktg)
	e12:SetOperation(s.atkop)
	c:RegisterEffect(e12)
end
function s.cfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.get_set_card_count(tp)
	return Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_SZONE,0,nil)
end
function s.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return s.get_set_card_count(1-Duel.GetTurnPlayer())<=4
end
function s.skipop(e,tp,eg,ep,ev,re,r,rp)
	local p=1-Duel.GetTurnPlayer()
	if Duel.SelectYesNo(p,aux.Stringid(51670553,0)) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
		Duel.RegisterEffect(e1,p)
	else
		Duel.Hint(HINT_OPSELECTED,1-p,aux.Stringid(51670553,0))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SSET)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,p)
	end
end
function s.con(e)
	local p=math.abs(e:GetLabel()-e:GetHandlerPlayer())
	return s.get_set_card_count(p)<=4
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) or s.get_set_card_count(tp)~=5 then return false end
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local e1,e2,e3=s[e]()
	return s[cid]==tp and (re==e1 or re==e2 or re==e3)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		Duel.BreakEffect()
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(tc:GetBaseAttack()*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
function s.endtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	s[cid]=rp
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetTurnPlayer()
	Duel.SkipPhase(p,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(p,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(p,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(p,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(p,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(p,PHASE_END,RESET_PHASE+PHASE_END,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW or Duel.GetTurnPlayer()~=tp
end
function s.setfilter(c,e,tp)
	return c:IsControler(tp) and (c:IsMSetable(true,nil) or c:IsSSetable(true)) and (not e or c:IsRelateToEffect(e))
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.cfilter,1,nil,nil,tp) end
	Duel.SetTargetCard(eg)
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	s[cid]=tp
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=eg:Filter(s.setfilter,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		if tc:IsMSetable(true,nil) and (not tc:IsSSetable(true) or Duel.SelectYesNo(tp,aux.Stringid(80604091,3))) then
			Duel.MSet(tp,tc,true,nil)
		else
			Duel.SSet(tp,tc)
		end
		tc=g:GetNext()
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,5,nil)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterEqualFunction(Card.GetFlagEffect,0,id),tp,LOCATION_MZONE,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterEqualFunction(Card.GetFlagEffect,0,id),tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		tc=g:GetNext()
	end
end
