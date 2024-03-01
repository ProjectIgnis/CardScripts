--オーバーレイ・マーカー
--Overlay Marker
--Originally scripted by Shad3
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.cd)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--Global Check
	aux.GlobalCheck(s,function()
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DETACH_MATERIAL)
		ge1:SetOperation(s.flag_op)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.flag_op(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetCurrentChain()
	if cid>0 then s['det_chk']=Duel.GetChainInfo(cid,CHAININFO_CHAIN_ID) end
end
function s.cd(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker() and Duel.GetAttackTarget()
		and Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==s['det_chk']
		and re:IsActiveType(TYPE_XYZ) and re:GetHandler():GetOverlayCount()==0 and Duel.IsChainNegatable(ev)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	local val=Duel.GetAttacker():GetAttack()+Duel.GetAttackTarget():GetAttack()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(re:GetHandler(),REASON_EFFECT)>0 then
		local val=0
		if Duel.GetAttacker() then val=val+Duel.GetAttacker():GetAttack() end
		if Duel.GetAttackTarget() then val=val+Duel.GetAttackTarget():GetAttack() end
		if val>0 then
			Duel.BreakEffect()
			local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
			Duel.Damage(p,val,REASON_EFFECT)
		end
	end
end