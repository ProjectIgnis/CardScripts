--ワクチンゲール
--Antidote Nurse
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 3 monsters
	Xyz.AddProcedure(c,nil,3,2,nil,nil,Xyz.InfiniteMats)
	--Change the ATK/DEF of a monster whose current ATK and/or DEF is different from its original value to its original ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(function() return not (Duel.IsPhase(PHASE_DAMAGE) and Duel.IsDamageCalculated()) end)
	e1:SetCost(Cost.Detach(1,1,nil))
	e1:SetTarget(s.changeatkdeftg)
	e1:SetOperation(s.changeatkdefop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Make a monster(s) Special Summoned to your field gain 900 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.FaceupFilter(Card.IsControler,tp),1,nil) end)
	e2:SetTarget(s.gainatktg)
	e2:SetOperation(s.gainatkop)
	c:RegisterEffect(e2)
end
function s.changeatkdeffilter(c)
	return not (c:IsAttack(c:GetBaseAttack()) and c:IsDefense(c:GetBaseDefense()))
end
function s.changeatkdeftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.changeatkdeffilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.changeatkdeffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectTarget(tp,s.changeatkdeffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	e:SetLabel(tc:IsControler(tp) and 1 or 0)
end
function s.changeatkdefop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		--Its ATK/DEF become its original ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense())
		tc:RegisterEffect(e2)
		Duel.AdjustInstantly(tc)
		if not (tc:IsAttack(tc:GetBaseAttack()) and tc:IsDefense(tc:GetBaseDefense()) and e:GetLabel()==1) then return end
		Duel.BreakEffect()
		--Cannot be destroyed by battle or card effects this turn
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(3008)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetValue(1)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		tc:RegisterEffect(e4)
	end
end
function s.gainatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(aux.FaceupFilter(Card.IsControler,tp),nil):Match(Card.IsLocation,nil,LOCATION_MZONE)
	if chk==0 then return e:GetHandler():GetOverlayCount()>=3 and #g>0 end
	Duel.SetTargetCard(g)
end
function s.gainatkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		--That monster(s) gains 900 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(900)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
