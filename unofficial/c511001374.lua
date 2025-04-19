--Ｎｏ．８ 紋章王ゲノム・ヘリター (Anime)
--Number 8: Heraldic King Genom-Heritage (anime)
Duel.LoadCardScript("c47387961.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HERALDIC_BEAST),4,2)
	--Cannot be destroyed by battle, except with a "Number" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--Choose 1 of these effects (Attack Change, Effect Gain, Name Gain)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_BATTLE_PHASE,TIMING_BATTLE_PHASE)
	e2:SetCost(Cost.Detach(1))
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={SET_NUMBER}
s.listed_names={CARD_UNKNOWN}
s.xyz_number=8
function s.efffilter(c)
	return c:IsNegatableMonster() and c:IsAttackPos()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local b1=true
	local b2=Duel.IsExistingMatchingCard(s.efffilter,tp,0,LOCATION_MZONE,1,nil)
	local tchk,teg=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE,true)
	local b3=tchk and teg:GetFirst():IsControler(1-tp) and not teg:GetFirst():IsCode(511001375)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)},{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==2 then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE) 
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		--Change opponent monster's ATK to 0 and the ATK of this card to that original ATK
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_ATKCHANGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetCondition(s.atkcon)
		e1:SetOperation(s.atkop)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	elseif op==2 then
		--Negate the effects of 1 opponent's Attack Position monster and this card gains those effects
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local sc=Duel.SelectMatchingCard(tp,s.efffilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if sc and not sc:IsStatus(STATUS_DISABLED) then
			local code=sc:GetOriginalCode()
			sc:NegateEffects(c,RESETS_STANDARD_PHASE_END)
			c:CopyEffect(code,RESETS_STANDARD_PHASE_END)
		end
	elseif op==3 then
		local a=Duel.GetAttacker()
		local code=a:GetOriginalCode()
		if a:IsFaceup() and a:IsRelateToBattle() and not a:IsImmuneToEffect(e) then
			--Attacker's name becomes "Unknown"
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetValue(CARD_UNKNOWN)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			a:RegisterEffect(e1)
			if c:IsFaceup() and c:IsRelateToEffect(e) then
				--This card's name gains the name of the attacking monster
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_ADD_CODE)
				e2:SetValue(code)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD)
				c:RegisterEffect(e2)
			end
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() 
		and bc:GetBaseAttack()~=c:GetAttack() and bc:HasNonZeroAttack()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(bc:GetBaseAttack())
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		bc:RegisterEffect(e1)
	end
end