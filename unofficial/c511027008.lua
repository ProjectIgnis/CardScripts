--ハイドライブ・グラヴィティ
--Hydradrive Gravity
--Scripted by Playmaker 772211
--Fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Move
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsInExtraMZone() and c:IsType(TYPE_LINK)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc==Duel.GetAttacker() end
	local tg=Duel.GetAttacker()
	local zone=aux.GetMMZonesPointedTo(tp,s.cfilter,LOCATION_MZONE,0,1-tp)
	if chk==0 then return zone>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_COUNT,zone)>0
		and tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tg)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(tp) or tc:IsImmuneToEffect(e)
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_COUNT,zone)==0 then return end
	local zone=aux.GetMMZonesPointedTo(tp,s.cfilter,LOCATION_MZONE,0,1-tp)
	if zone==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,~zone<<16)>>16,2))
end
function s.handcon(e)
	local a=Duel.GetAttacker()
	return a and a:GetAttack()>a:GetBaseAttack()
end