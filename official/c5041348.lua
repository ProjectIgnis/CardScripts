--天威の龍鬼神
--Draco Berserker of the Tenyi
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Synchro summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Banish opponent's monster, that activated its effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--Gains ATK, also can make a second attack on monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and re:GetHandler():IsRelateToEffect(re)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsAbleToRemove() and not rc:IsLocation(LOCATION_REMOVED) end
	Duel.SetTargetCard(rc)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(e) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return Duel.GetAttacker()==c and c:IsRelateToBattle()
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_EFFECT)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or not c:IsRelateToBattle() then return end
	local tc=Duel.GetFirstTarget()
	local value=tc:GetBaseAttack()
	if value<0 then value=0 end
	--Gains ATK equal to destroyed monster's original ATK
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(value)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
	--Can make a second attack on monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3202)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end