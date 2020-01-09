--イクイップ・シュート
--Equip Shot
local s,id=GetID()
function s.initial_effect(c)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
function s.filter1(c,e,tp)
	local ec=c:GetEquipTarget()
	return ec and ec:IsControler(tp) and ec:IsPosition(POS_FACEUP_ATTACK)
		and Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil,c)
end
function s.filter2(c,ec)
	return c:IsPosition(POS_FACEUP_ATTACK) and ec:CheckEquipTarget(c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,g1:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g1,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetLabelObject()
	local eqc=eq:GetEquipTarget()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if eq==tc then tc=g:GetNext() end
	if eqc and eq:IsRelateToEffect(e) then
		if Duel.Equip(tp,eq,tc)==0 then return end
		Duel.BreakEffect()
		local a=eqc
		local d=tc
		if Duel.GetTurnPlayer()~=tp then
			a=tc
			d=eqc
		end
		if a:CanAttack() and not a:IsImmuneToEffect(e) and not d:IsImmuneToEffect(e) then
			Duel.CalculateDamage(a,d,true)
		end
	end
end
