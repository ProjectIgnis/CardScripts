--天馬の翼
--Pegasus Wing
--Scripted by Eerie Code

local s,id=GetID()
function s.initial_effect(c)
	--Your "Valkyrie" monsters can attack directly, halve their battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x122}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_UNION) and Duel.IsAbleToEnterBP()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local f=aux.FaceupFilter(Card.IsSetCard,0x122)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and f(chkc) end
	if chk==0 then return Duel.IsExistingTarget(f,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,f,tp,LOCATION_MZONE,0,1,99,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #g>0 then g:ForEach(s.op,e:GetHandler()) end
end
function s.op(tc,c)
	--Can attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3205)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	--Halve battle damage inflicted
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(s.rdcon)
	e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e2)
	tc:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD|RESET_DISABLE)&~(RESET_LEAVE)|RESET_PHASE|PHASE_END,0,1)
end
function s.rdcon(e)
	local c,tp=e:GetHandler(),e:GetHandlerPlayer()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and c:GetFlagEffect(id)>0
end