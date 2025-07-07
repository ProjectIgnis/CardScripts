--Ｎｏ．８７ 雪月花美神クイーン・オブ・ナイツ
--Number 87: Queen of the Night
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 8 monsters
	Xyz.AddProcedure(c,nil,8,3)
	--Ativate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCost(Cost.Detach(1))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.xyz_number=87
function s.setfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsCanTurnSet()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local op=e:GetLabel()
		if op==1 then
			return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown()
		elseif op==2 then
			return chkc:IsLocation(LOCATION_MZONE) and s.setfilter(chkc)
		elseif op==3 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
		end
	end
	local not_dmg_step=Duel.GetCurrentPhase()~=PHASE_DAMAGE
	local b1=not_dmg_step and Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil)
	local b2=not_dmg_step and Duel.IsExistingTarget(s.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b3=aux.StatChangeDamageStepCondition(e,tp,eg,ep,ev,re,r,rp)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
		Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		--Target 1 Set Spell/Trap your opponent controls; while this card is face-up on the field, that Set card cannot be activated
		if c:IsRelateToEffect(e) and tc:IsFacedown() then
			c:SetCardTarget(tc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetCondition(function(e) return e:GetOwner():IsHasCardTarget(e:GetHandler()) end)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	elseif op==2 then
		--Target 1 Plant monster on the field; change that target to face-down Defense Position
		if tc:IsFaceup() then
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	elseif op==3 then
		--Target 1 face-up monster on the field; that target gains 300 ATK
		if tc:IsFaceup() then
			tc:UpdateAttack(300,nil,c)
		end
	end
end
