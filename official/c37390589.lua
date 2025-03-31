--鎖付きブーメラン
--Kunai with Chain
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 or both of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	local ac=Duel.GetAttacker()
	local b1=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and ac:IsControler(1-tp) and ac:IsLocation(LOCATION_MZONE) and ac:IsAttackPos()
		and ac:IsCanChangePosition() and ac:IsCanBeEffectTarget(e)
	local b2=e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b1 and b2,aux.Stringid(id,3)})
	Duel.SetTargetParam(op)
	e:SetCategory(0)
	if op==1 or op==3 then
		e:SetCategory(CATEGORY_POSITION)
		Duel.SetTargetCard(ac)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,ac,1,tp,0)
	end
	if op==2 or op==3 then
		e:SetCategory(e:GetCategory()|CATEGORY_EQUIP)
		if e:GetLabel()==1 then
			aux.RemainFieldCost(e,tp,eg,ep,ev,re,r,rp,1)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
		e:SetLabelObject(g:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	end
	e:SetLabel(0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 or op==3 then
		--Change the attacking monster to Defense Position
		local tc=Duel.GetAttacker()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:CanAttack() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
	end
	if op==2 or op==3 then
		--Equip this card to a face-up monster you control
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
		local tc=e:GetLabelObject()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and Duel.Equip(tp,c,tc) then
			--It gains 500 ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e1)
			--Equip limit
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_EQUIP_LIMIT)
			e2:SetValue(function(_e,_c) return _c:IsControler(tp) end)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e2)
		else
			c:CancelToGrave(false)
		end
	end
end