--Grazing Bullet
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function s.filter(c,e)
	return (not e and c:IsPosition(POS_FACEUP_ATTACK)) or (e and c:IsFaceup() and c:IsRelateToEffect(e))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,nil) 
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local g2=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,g2:GetFirst():GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g1:GetFirst():GetAttack())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.filter,nil,e)
	local g1=g:Filter(Card.IsControler,nil,tp)
	local g2=g:Filter(Card.IsControler,nil,1-tp)
	local sum1=g1:GetSum(Card.GetAttack)
	local sum2=g2:GetSum(Card.GetAttack)
	Duel.Damage(tp,sum2,REASON_EFFECT,true)
	Duel.Damage(1-tp,sum1,REASON_EFFECT,true)
	Duel.RDComplete()
	local tc=g2:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		tc=g2:GetNext()
	end
end
