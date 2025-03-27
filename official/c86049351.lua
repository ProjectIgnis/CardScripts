--ラスト・カウンター
--Last Counter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_BATTLIN_BOXER}
function s.cfilter(c,pos)
	return c:IsPosition(pos) and c:IsSetCard(SET_BATTLIN_BOXER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc1,bc2=Duel.GetBattleMonster(tp)
	if not (bc1 and bc1:IsFaceup() and bc1:IsSetCard(SET_BATTLIN_BOXER)) then return false end
	if not (bc2 and bc2:IsFaceup()) then return false end
	local pos=POS_FACEUP
	if bc1==Duel.GetAttacker() then pos=POS_FACEUP_ATTACK end
	e:SetLabelObject(bc1)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,bc1,pos)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,e:GetLabelObject():GetBattleTarget():GetBaseAttack())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not (Duel.NegateAttack() and tc:IsRelateToBattle()) then return end
	if tc:IsControler(tp) and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		local bc=tc:GetBattleTarget()
		if not (bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp)) then return end
		local pos=POS_FACEUP
		if tc==Duel.GetAttacker() then pos=POS_FACEUP_ATTACK end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local sc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,pos):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc,true)
		local atk=bc:GetBaseAttack()
		if atk<0 then atk=0 end
		--Increase ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
		if bc==Duel.GetAttackTarget() then bc,sc=sc,bc end
		if sc:IsCanBeBattleTarget(bc) and not bc:IsImmuneToEffect(e) and not sc:IsImmuneToEffect(e) then
			Duel.CalculateDamage(bc,sc)
			Duel.BreakEffect()
			Duel.Damage(tp,atk,REASON_EFFECT)
		end
	end
end