--ガリバー・チェーン
--Gulliver Chain
local s,id=GetID()
function s.initial_effect(c)
	--When a monster(s) on the field changes its position: Target 1 of those monsters; change that target to face-up Defense Position.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabelObject(e1)
	e2:SetCondition(aux.PersistentTgCon)
	e2:SetOperation(aux.PersistentTgOp(true))
	c:RegisterEffect(e2)
	--When the targeted monster is changed to Attack Position, destroy it and this card.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.filter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.filter,nil,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(tc)
	if not tc:GetFirst():IsPosition(POS_FACEUP_DEFENSE) then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsAttackPos()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	local g=Group.FromCards(tc,c)
	Duel.Destroy(g,REASON_EFFECT)
end
