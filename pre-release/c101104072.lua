--Ａ・Ɐ・ＷＷ
--Amaze Ɐttraction Wonder Wheel
--Scripted by Eerie Code

local s,id=GetID()
function s.initial_effect(c)
	--From cards_specific_functions.lua
	aux.AddAttractionEquipProc(c)
	--Activate 1 of 2 effects, depending on equipped monster's controller.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.cond)
	e2:SetTarget(s.tg)
	c:RegisterEffect(e2)
end
s.listed_series={0x25d}
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local et=e:GetHandler():GetEquipTarget()
	if not et then return false end
	local yours=et:GetControler()==tp
	if chk==0 then
		if yours then
			return s.drcon(e,tp,eg,ep,ev,re,r,rp) and s.drtg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return s.atktg(e,tp,eg,ep,ev,re,r,rp,0)
		end
	end
	if yours then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		e:SetOperation(s.drop)
		s.drtg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
		e:SetOperation(s.atkop)
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(p,aux.TRUE,p,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoDeck(g,nil,1,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.Draw(p,1,REASON_EFFECT)
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	if chk==0 then return tc and tc:HasDefense() end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if tc and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(def)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
