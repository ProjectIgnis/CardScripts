--No.102 光天使グローリアス・ヘイロー (Anime)
--Number 102: Star Seraph Sentry (Anime)
--Re-scripted by The Razgriz
Duel.LoadCardScript("c49678559.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),4,3)
	--Cannot be destroyed by battle with non-"Number" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--Negate the effects of 1 monster your opponent controls and halve its ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49678559,0))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(Cost.Detach(1))
	e2:SetTarget(s.disatkchtg)
	e2:SetOperation(s.disatkchop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--Detach all materials from this to prevent this card's destruction (Battle)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(s.indescon)
	e3:SetCost(s.indescost)
	e3:SetTarget(s.indestg)
	e3:SetOperation(s.indesop)
	c:RegisterEffect(e3)
	--Detach all materials from this to prevent this card's destruction (Card effect)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.indescon2)
	c:RegisterEffect(e4)
end
s.listed_series={SET_NUMBER}
s.xyz_number=102
function s.disatkchfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end
function s.disatkchtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disatkchfilter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.disatkchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.disatkchfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		Duel.HintSelection(tc,true)
		tc:NegateEffects(c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()/2)
		tc:RegisterEffect(e1)
	end
end
function s.indescon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	local bc=tc:GetBattleTarget()
	if not bc then return false end
	if tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
		local tcind={tc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
		for _,te in ipairs(tcind) do
			local f=te:GetValue()
			if type(f)=='function' then
				if f(te,bc) then return false end
			else return false end
		end
	end
	if bc==Duel.GetAttackTarget() and bc:IsDefensePos() then return false end
	if bc:IsPosition(POS_FACEUP_DEFENSE) and bc==Duel.GetAttacker() then
		if not bc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then return false end
		if bc:IsHasEffect(75372290) then
			if tc:IsAttackPos() then
				return bc:GetAttack()>0 and bc:GetAttack()>=tc:GetAttack()
			else
				return bc:GetAttack()>tc:GetDefense()
			end
		else
			if tc:IsAttackPos() then
				return bc:GetDefense()>0 and bc:GetDefense()>=tc:GetAttack()
			else
				return bc:GetDefense()>tc:GetDefense()
			end
		end
	else
		if tc:IsAttackPos() then
			return bc:GetAttack()>0 and bc:GetAttack()>=tc:GetAttack()
		else
			return bc:GetAttack()>tc:GetDefense()
		end
	end
end
function s.indescon2(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg and tg:IsContains(e:GetHandler())
end
function s.indescost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()
	if chk==0 then return ct>0 and c:CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
function s.indestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		if e:GetCode()==EVENT_PRE_DAMAGE_CALCULATE then
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetTargetRange(1,0)
			e2:SetValue(HALF_DAMAGE)
			e2:SetReset(RESET_PHASE|PHASE_DAMAGE_CAL)
			Duel.RegisterEffect(e2,tp)
		else
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetValue(function(e,te) return re==te end)
			e1:SetReset(RESET_CHAIN)
		end
		c:RegisterEffect(e1)
	end
end