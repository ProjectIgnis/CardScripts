--ニトロ・ウォリアー
--Nitro Warrior
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: "Nitro Synchron" + 1 or more non-Tuner monsters
	Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTuner(nil),1,99)
	--Register Spell card activations
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0a:SetCode(EVENT_CHAINING)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp and Duel.IsTurnPlayer(tp) end)
	e0a:SetOperation(aux.chainreg)
	c:RegisterEffect(e0a)
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0b:SetCode(EVENT_CHAIN_SOLVED)
	e0b:SetRange(LOCATION_MZONE)
	e0b:SetOperation(s.regop)
	c:RegisterEffect(e0b)
	--Once during each of your turns, if you activate a Spell Card, this card gains 1000 ATK during the next attack involving this card, during damage calculation only
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCondition(s.atkcon)
	e1a:SetValue(1000)
	c:RegisterEffect(e1a)
	--Reset the flag effect above if this card attacks again
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1b:SetCode(EVENT_BATTLED)
	e1b:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e1b:SetOperation(function(e) e:GetHandler():ResetFlagEffect(id) end)
	c:RegisterEffect(e1b)
	--Change 1 Defense Position monster your opponent controls to Attack Position, then this card can make a second attack against that monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(s.chainattackposcon)
	e2:SetTarget(s.chainattackpostg)
	e2:SetOperation(s.chainattackposop)
	c:RegisterEffect(e2)
end
s.material={96182448} --"Nitro Synchron"
s.listed_names={96182448} --"Nitro Synchron"
s.material_setcode=SET_SYNCHRON
function s.tunerfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,96182448) or c:IsHasEffect(20932152) --"Quickdraw Synchron" check
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect() and e:GetHandler():GetFlagEffect(1)>0 then
		e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c and c:HasFlagEffect(id) and Duel.IsPhase(PHASE_DAMAGE_CAL)
end
function s.chainattackposcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and c:CanChainAttack()
end
function s.chainattackposfilter(c)
	return c:IsFaceup() and c:IsDefensePos() and not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsCanChangePosition()
end
function s.chainattackpostg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.chainattackposfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.chainattackposfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.chainattackposfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.chainattackposop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		Duel.ChainAttack(tc)
	end
end
