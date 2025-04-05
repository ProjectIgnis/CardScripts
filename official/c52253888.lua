--ライトローミディアム
--Light Law Medium
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Targets must attack this card, if able
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Negate the attack and inflict damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
function s.atkfilter(c,e)
	return c:IsAttackPos() and c:IsCanBeEffectTarget(e)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAttackPos() end
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,#g,nil,e)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	for tc in tg:Iter() do
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1,c:GetFieldID())
	end
	--Must attack this card, if able
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.musttg)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(function(e,c) return c==e:GetHandler() end)
	c:RegisterEffect(e2)
end
function s.musttg(e,c)
	return c:GetFlagEffectLabel(id) and c:GetFlagEffectLabel(id)==e:GetHandler():GetFieldID()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local bc0,bc1=Duel.GetBattleMonster(tp)
	return bc0 and bc0==e:GetHandler() and bc1 and bc1:IsAttackPos() and bc1:GetBaseAttack()>0
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local _,bc1=Duel.GetBattleMonster(tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc1:GetBaseAttack()/2)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateAttack() then return end
	local _,bc1=Duel.GetBattleMonster(tp)
	if not (bc1:IsFaceup() and bc1:IsControler(1-tp) and bc1:IsRelateToBattle()) then return end
	Duel.Damage(1-tp,bc1:GetBaseAttack()/2,REASON_EFFECT)
end