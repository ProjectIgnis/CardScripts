--デステニー・ストリングス
--String of Destiny
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_GIMMICK_PUPPET))
	--to grave
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCost(s.atcost)
	e1:SetCondition(s.atcon)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	Duel.DiscardDeck(tp,1,REASON_COST)
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc:IsMonster() then
		e:SetLabel(tc:GetLevel()-1)
	else
		e:SetLabel(0)
	end
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipTarget() end
	Duel.SetTargetCard(e:GetHandler():GetEquipTarget())
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and lv>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		--battle
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCode(EVENT_BATTLE_CONFIRM)
		e2:SetCondition(s.indescon)
		e2:SetOperation(s.indesop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	else
		if Duel.NegateAttack() then
			Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		end
	end
end
function s.indescon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	return bc and bc:IsAttackPos()
end
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	bc:RegisterEffect(e1,true)
end