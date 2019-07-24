--進化への懸け橋
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(aux.PersistentTgCon)
	e2:SetOperation(aux.PersistentTgOp(true))
	c:RegisterEffect(e2)
	--eff
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(aux.PersistentTargetFilter)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	--be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttackTarget()
	if chkc then return chkc==tg and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return tg and tg:IsOnField() and tg:IsControler(tp) and tg:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tg)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.NegateAttack()
	end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local tc=c:GetFirstCardTarget()
	if tg:IsContains(tc) and tc:IsLocation(LOCATION_MZONE) and Duel.SelectEffectYesNo(tp,c) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.SendtoGrave(c,REASON_EFFECT)
		local rg=Group.CreateGroup()
		rg:Merge(tg)
		rg:RemoveCard(tc)
		Duel.ChangeTargetCard(ev,rg)
	end
end
