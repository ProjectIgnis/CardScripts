--プリズム・ウォール
--Prism Wall
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--change target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and at:IsControler(1-tp)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ag=eg:GetFirst():GetAttackableTarget()
	if chkc then return ag:IsContains(chkc) and chkc:IsCanBeEffectTarget(e) end
	local at=Duel.GetAttackTarget()
	if chk==0 then return ag:IsExists(Card.IsCanBeEffectTarget,1,at,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=ag:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,at,e)
	Duel.SetTargetCard(g)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.ChangeAttackTarget(tc) then
		Duel.BreakEffect()
		local dam=tc:GetAttack()
		Duel.Damage(1-tp,dam,REASON_EFFECT,true)
		Duel.Damage(tp,dam,REASON_EFFECT,true)
		Duel.RDComplete()
	end
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not re:IsActiveType(TYPE_MONSTER) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not rc:IsControler(1-tp) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE)
end
function s.filter2(c,re,rp,tf,ceg,cep,cev,cre,cr,crp)
	return tf(re,rp,ceg,cep,cev,cre,cr,crp,0,c)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tf=re:GetTarget()
	local res,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(re:GetCode(),true)
	if chkc then return chkc~=e:GetLabelObject() and chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(tp) and tf(re,rp,ceg,cep,cev,cre,cr,crp,0,chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,e:GetLabelObject(),re,rp,tf,ceg,cep,cev,cre,cr,crp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,e:GetLabelObject(),re,rp,tf,ceg,cep,cev,cre,cr,crp)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if #g>0 and g:GetFirst():IsRelateToEffect(e) then
		Duel.ChangeTargetCard(ev,g)
		Duel.BreakEffect()
		local dam=g:GetFirst():GetAttack()
		Duel.Damage(1-tp,dam,REASON_EFFECT,true)
		Duel.Damage(tp,dam,REASON_EFFECT,true)
		Duel.RDComplete()
	end
end