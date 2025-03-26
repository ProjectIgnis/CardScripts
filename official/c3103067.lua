--攻撃誘導アーマー
--Attack Guidance Armor
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Destroy the attacking monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Change the attack target
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(0)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local label=e:GetLabel()
	local bc=Duel.GetAttacker()
	local excg=Group.FromCards(bc)
	local dc=Duel.GetAttackTarget()
	if dc then excg:AddCard(dc) end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and not excg:IsContains(chkc) end
	if chk==0 then
		if label==0 then
			return bc:IsOnField()
		else
			return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,excg)
		end
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,label))
	if label==0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
		Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,excg)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetLabel()
	local bc=Duel.GetAttacker()
	local tc=Duel.GetFirstTarget()
	if label==0 and bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	elseif label==1 and bc:CanAttack() and not bc:IsImmuneToEffect(e)
		and tc and tc:IsRelateToEffect(e) then
		Duel.CalculateDamage(bc,tc)
	end
end